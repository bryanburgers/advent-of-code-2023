(module
    (export "main" (func $main))
    (export "memory" (memory $memory))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))
    (import "dbg" "i32" (func $dbg.i32 (param i32)))

    (memory $memory 1)

    (func $main
        (result i32)
        (local $input_len i32)
        
        call $aoc.input_len
        local.set $input_len

        i32.const 0
        call $aoc.input
        drop

        i32.const 0
        local.get $input_len
        call $parse_input
    )

    ;; Attempt to parse a single digit from the input
    (func $parse_digit
        (param $offset i32)
        (result i32 (; the value, if successful ;))
        (result i32 (; 1 if successful, 0 if not ;))

        (local $val i32)
        (local $success i32)

        ;; get byte from memory
        local.get $offset
        i32.load8_u

        ;; subtract "0" to transform a digit into the value 0-9
        i32.const 0x30 ;; ascii for "0"
        i32.sub
        local.tee $val

        ;; check to see if it's actually a digit by comparing it to 9
        i32.const 9
        i32.le_u
        local.set $success

        ;; return the value (if it's valid) or zero
        local.get $val
        i32.const 0
        local.get $success
        select

        ;; and return whether it was successful
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

    ;; Parse an entire line from the input
    (func $parse_line
        (param $offset i32)
        (result i32 (; the value of the line ;))
        (result i32 (; how many bytes were parsed ;))

        (local $current_offset i32)
        (local $first_digit i32)
        (local $last_digit i32)
        (local $parsed i32)
        (local $parse_digit_r1 i32)
        (local $parse_digit_r2 i32)

        (local.set $first_digit (i32.const -1))
        (local.set $last_digit (i32.const -1))
        (local.set $current_offset (local.get $offset))

        (block $block
            (loop $loop
                local.get $parsed
                local.get $offset
                i32.add
                local.set $current_offset

                local.get $current_offset
                call $parse_newline

                (if
                    (then
                        local.get $parsed
                        i32.const 1
                        i32.add
                        local.set $parsed
                        br $block
                    )
                )

                local.get $current_offset
                call $parse_digit
                local.set $parse_digit_r2
                local.set $parse_digit_r1

                (if (local.get $parse_digit_r2)
                    (then
                        ;; This is certainly the last digit we've seen. Set it
                        (local.set $last_digit (local.get $parse_digit_r1))

                        ;; Is this the first digit we've seen?
                        (block $local
                            local.get $first_digit
                            i32.const -1
                            i32.gt_s
                            br_if $local

                            (local.set $first_digit (local.get $parse_digit_r1))
                        )
                        
                        local.get $parsed
                        local.get $parse_digit_r2
                        i32.add
                        local.set $parsed

                        br $loop
                    )
                )

                ;; the byte was neither a newline nor a digit
                ;; skip over it
                local.get $parsed
                i32.const 1
                i32.add
                local.set $parsed
                br $loop
            )
        )

        (i32.add
            (i32.mul
                (i32.const 10)
                (local.get $first_digit)
            )
            (local.get $last_digit)
        )
        local.get $parsed
    )

    (func $parse_input
        (param $input_offset i32)
        (param $input_len i32)
        (result i32 (; puzzle answer ;))
        
        (local $sum i32)
        (local $parsed i32)
        (local $current_offset i32)
        (local $parse_line_r1 i32)
        (local $parse_line_r2 i32)

        (local.set $sum (i32.const 0))
        (local.set $parsed (i32.const 0))

        (block $block
            (loop $loop
                local.get $input_offset
                local.get $parsed
                i32.add
                local.tee $current_offset

                call $parse_line
                local.set $parse_line_r2
                local.set $parse_line_r1

                ;; if no input was parsed, stop doing anything.
                local.get $parse_line_r2
                i32.eqz
                br_if $block

                ;; increment the number of parsed bytes
                local.get $parsed
                local.get $parse_line_r2
                i32.add
                local.set $parsed

                ;; calculate the sum
                local.get $sum
                local.get $parse_line_r1
                i32.add
                local.set $sum

                (; call $dbg.i32 (local.get $parse_line_r1) ;)

                ;; have we parsed to the end of the input
                local.get $parsed
                local.get $input_len
                i32.lt_u
                br_if $loop
            )
        )

        local.get $sum
    )
)