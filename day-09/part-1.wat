(module
    (export "main" (func $main))
    (export "memory" (memory $mem))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))
    (import "dbg" "mem:24:sequence" (func $dbg.sequence (param i32) (result i32)))
    (import "dbg" "inspect:solved" (func $dbg.solved (param i32) (result i32)))
    (import "dbg" "inspect:reduce_one" (func $dbg.reduce_one (param i32) (result i32)))

    (memory $mem 1)

    (global $input_len (mut i32) (i32.const 0))

    ;; our main function!
    (func $main (result i32)
        (global.set $input_len
            (call $aoc.input
                (i32.const 0)))
        
        (call $solve)
    )

    (func $solve
        (result i32)

        (local $offset i32)
        (local $parsed i32)
        (local $sum i32)
        (local $n i32)
        (local $next_in_sequence i32)

        (loop $continue
            (call $parse_line
                (local.get $offset))
            local.set $parsed
            local.set $n

            ;; (drop (call $dbg.sequence (global.get $input_len)))

            (local.set $offset
                (i32.add
                    (local.get $offset)
                    (local.get $parsed)))

            (local.set $next_in_sequence 
                (call $solve_line
                    (local.get $n)))
            
            (local.set $sum
                (i32.add
                    (local.get $sum)
                    (local.get $next_in_sequence)))

            (br_if $continue
                (i32.lt_u
                    (local.get $offset)
                    (global.get $input_len)))
        )

        local.get $sum
    )

    ;; Parse a line and put the results in the well-known scratch space
    (func $parse_line
        (param $offset i32)
        (result (; the number of items parsed ;) i32)
        (result (; bytes read ;) i32)

        (local $current_offset i32)
        (local $items_parsed i32)
        (local $parse_number_bytes i32)
        (local $parse_number_value i32)

        (local.set $current_offset (local.get $offset))

        (block $break
            (loop $continue
                (if (call $parse_newline (local.get $current_offset))
                    (then
                        (local.set $current_offset
                            (i32.add
                                (local.get $current_offset)
                                (i32.const 1)))
                        br $break
                    )
                )

                (call $i32.parse_from_memory_s (local.get $current_offset))
                local.set $parse_number_bytes
                local.set $parse_number_value

                (local.set $current_offset
                    (i32.add
                        (local.get $current_offset)
                        (local.get $parse_number_bytes)))

                (call $store_location (local.get $items_parsed) (local.get $parse_number_value))

                (if (call $parse_space (local.get $current_offset))
                    (then
                        (local.set $current_offset
                            (i32.add
                                (local.get $current_offset)
                                (i32.const 1)))
                    )
                )

                (local.set $items_parsed
                    (i32.add
                        (local.get $items_parsed)
                        (i32.const 1)))

                br $continue
            )
        )

        (local.get $items_parsed)
        (i32.sub
            (local.get $current_offset)
            (local.get $offset))
    )

    ;; Solve a line from the well-known scratch space
    (func $solve_line
        (param $len i32)
        (result i32)

        (local $n i32)
        (local $sum i32)

        (local.set $n
            (local.get $len))

        (loop $loop
            (call $reduce_one
                (local.get $n))

            ;; (drop (call $dbg.sequence (global.get $input_len)))

            (local.set $n
                (i32.sub
                    (local.get $n)
                    (i32.const 1)))

            (br_if $loop
                (i32.gt_s
                    (local.get $n)
                    (i32.const 0)))
        )

        (local.set $n
            (local.get $len))

        (loop $loop
            (local.set $sum
                (i32.add
                    (local.get $sum)
                    (call $load_location
                        (local.get $n))))

            (local.set $n
                (i32.sub
                    (local.get $n)
                    (i32.const 1)))

            (br_if $loop
                (i32.ge_s
                    (local.get $n)
                    (i32.const 0)))
        )

        local.get $sum
    )

    (func $reduce_one (param $len i32)
        (local $n i32)
    
        ;; (drop (call $dbg.reduce_one (local.get $len)))

        (block $break
            (loop $continue
                (br_if $break
                    (i32.ge_s
                        (local.get $n)
                        (i32.sub
                            (local.get $len)
                            (i32.const 1))))

                (call $store_location
                    (local.get $n)
                    (i32.sub
                        (call $load_location
                            (i32.add
                                (local.get $n)
                                (i32.const 1)))
                        (call $load_location
                            (local.get $n))))

                (local.set $n
                    (i32.add
                        (local.get $n)
                        (i32.const 1)))

                br $continue
            )
        )
    )

    (func $load_location (param $n i32) (result i32)
        (i32.load
            (i32.add
                (global.get $input_len)
                (i32.mul
                    (i32.const 4) ;; 4 bytes in an i32
                    (local.get $n)
                )
            )
        )
    )

    (func $store_location (param $n i32) (param $val i32)
        (i32.store
            (i32.add
                (global.get $input_len)
                (i32.mul
                    (i32.const 4) ;; 4 bytes in an i32
                    (local.get $n)
                )
            )
            (local.get $val)
        )
    )

    ;; Parse a number from the given memory offset as an i32
    (func $i32.parse_from_memory_s (param $offset i32) (result (;value;) i32 (;bytes read;) i32)
        (local $value i32)
        (local $bytes_read i32)

        (if (call $parse_minus (local.get $offset))
            (then
                (call $i32.parse_from_memory_u (i32.add (local.get $offset) (i32.const 1)))
                local.set $bytes_read
                local.set $value

                (local.set $bytes_read
                    (i32.add
                        (local.get $bytes_read)
                        (i32.const 1)))
                (local.set $value
                    (i32.sub
                        (i32.const 0)
                        (local.get $value)))
            )
            (else
                (call $i32.parse_from_memory_u (local.get $offset))
                local.set $bytes_read
                local.set $value
            )
        )

        local.get $value
        local.get $bytes_read
    )

    
    (func $i32.parse_from_memory_u (param $offset i32) (result (;value;) i32 (;bytes read;) i32)
        (local $current_offset i32)
        (local $accum i32)
        (local $consumed i32 (; the total number of bytes consumed;))
        
        ;; $current_offset = $offset
        local.get $offset
        local.set $current_offset

        (block $outer
            (loop $loop
                ;; get the next digit in memory
                local.get $current_offset
                call $i32.parse_byte_as_digit

                ;; at this point, top-1 is the value, top is how many bytes were consumed

                ;; if the number of bytes consumed was zero, we're done.
                i32.const 0
                i32.eq
                br_if $outer

                ;; at this point, top is the value parsed between 0 and 9 inclusive, as an i32

                ;; $accum = $accum * 10 + $digit
                local.get $accum
                i32.const 10
                i32.mul
                i32.add
                local.set $accum

                ;; $current_offset += 1
                local.get $current_offset
                i32.const 1
                i32.add
                local.set $current_offset

                ;; keep looping
                br $loop
            )
        )

        ;; $consumed = $current_offset - $offset
        local.get $current_offset
        local.get $offset
        i32.sub
        local.set $consumed

        ;; return our two values
        local.get $accum
        local.get $consumed
    )

    ;; Parse a single byte of memory as an i32, returning the value and the number of bytes read
    ;; note that the number of bytes read is either 1 or 0, so number of bytes read can also
    ;; be interpreted as whether the function succeeded or failed to find a number at the given offset
    (func $i32.parse_byte_as_digit (param $offset i32) (result (;value;) i32 (;bytes read;) i32)
        (local $parsed i32 (; the value that was parsed ;))
        (local $success i32 (; whether the value is actually a 0-9 digit ;))

        ;; ascii "0" is decimal 48, hex 0x30
        ;; so normalize the byte we received by subtracting that
        local.get $offset
        i32.load8_u
        i32.const 0x30
        i32.sub
        local.set $parsed
        
        ;; is it greater than or equal to 0? (wait, there's no gte instruction?)
        ;; (leave the result on the stack)
        local.get $parsed
        i32.const -1
        i32.gt_s

        ;; is it less than 10?
        ;; (leave the result on the stack)
        local.get $parsed
        i32.const 10
        i32.lt_s

        ;; top-1: is it greater than or equal to zero
        ;; top: is it less than 10
        ;; so we can and those two together.
        i32.and
        local.set $success

        ;; The parsed value, or 0 if a value couldn't be parsed
        ;;
        ;; this is just being kind. We could just return the weird normalized
        ;; value if it isn't between 0-9, and expect the caller to actually use
        ;; the "how many bytes were read/success" result to know whether it's
        ;; meaningful or not.
        ;;
        ;; if we were doing that, this would be as simple as
        ;;   local.get $parsed
        ;;
        ;; but I'm getting fancy. `select` looks at top and returns top-2 if it
        ;; is true or top-1 if it is false, so we can normalize our parsed value
        ;; pretty easily.
        local.get $parsed
        i32.const 0
        local.get $success
        select

        ;; How many bytes were read
        local.get $success
    )

    ;; Attempt to parse a newline from the input
    (func $parse_newline
        (param $offset i32)
        (result i32 (; 1 if successful, 0 if not ;))

        local.get $offset
        i32.load8_u
        i32.const 0x0a ;; "\n"
        i32.eq
    )

    (func $parse_space
        (param $offset i32)
        (result i32 (; 1 if successful, 0 if not ;))

        local.get $offset
        i32.load8_u
        i32.const 0x20 ;; " "
        i32.eq
    )

    (func $parse_minus
        (param $offset i32)
        (result i32 (; 1 if successful, 0 if not ;))

        local.get $offset
        i32.load8_u
        i32.const 0x2d ;; "-"
        i32.eq
    )
)