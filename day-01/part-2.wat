(module
    (export "main" (func $main))
    (export "memory" (memory $memory))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))
    (import "dbg" "i32" (func $dbg.i32 (param i32)))

    (memory $memory 1)
    (data (i32.const 0) "\03one")
    (data (i32.const 4) "\03two")
    (data (i32.const 8) "\05three")
    (data (i32.const 14) "\04four")
    (data (i32.const 19) "\04five")
    (data (i32.const 24) "\03six")
    (data (i32.const 28) "\05seven")
    (data (i32.const 34) "\05eight")
    (data (i32.const 40) "\04nine")
    ;; 45 bytes of static data before the input

    (func $main
        (result i32)
        (local $input_len i32)
        
        call $aoc.input_len
        local.set $input_len

        i32.const 45 ;; put the input starting at byte 45
        call $aoc.input
        drop

        i32.const 45 ;; input starts at byte 45
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

    ;; Attempt to parse a written number from this offset
    (func $parse_written_number
        (param $offset i32)
        (result i32 (; the value, if successful ;))
        (result i32 (; number of bytes parsed ;))

        (local $bytes i32)
        (local $number i32)

        (block $block (result i32 i32)
            ;; the number 1 is at offset 0
            local.get $offset
            i32.const 0
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 1
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 2 is at offset 4
            local.get $offset
            i32.const 4
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 2
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 3 is at offset 8
            local.get $offset
            i32.const 8
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 3
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 4 is at offset 14
            local.get $offset
            i32.const 14
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 4
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 5 is at offset 19
            local.get $offset
            i32.const 19
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 5
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 6 is at offset 24
            local.get $offset
            i32.const 24
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 6
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 7 is at offset 28
            local.get $offset
            i32.const 28
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 7
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 8 is at offset 34
            local.get $offset
            i32.const 34
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 8
                    local.get $bytes
                    br $block
                )
            )

            ;; the number 9 is at offset 40
            local.get $offset
            i32.const 40
            call $compare_to_static
            local.tee $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    i32.const 9
                    local.get $bytes
                    br $block
                )
            )

            ;; fallthrough
            i32.const 0
            i32.const 0
        )
    )

    (func $parse_number
        (param $offset i32)
        (result i32 (; the value ;))
        (result i32 (; how many bytes were parsed ;))

        (local $val i32)
        (local $bytes i32)

        (block $block (result i32 i32)
            local.get $offset
            call $parse_digit
            local.set $bytes
            local.set $val

            local.get $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    local.get $val
                    local.get $bytes
                    br $block
                )
            )

            local.get $offset
            call $parse_written_number
            local.set $bytes
            local.set $val

            local.get $bytes
            i32.const 0
            i32.gt_u
            (if
                (then
                    local.get $val
                    local.get $bytes
                    br $block
                )
            )

            ;; fallthrough: not a number
            i32.const 0
            i32.const 0
        )
    )

    ;; Determine if the bytes starting at $offset are a written number by
    ;; comparing them to a number
    (func $compare_to_static
        (param $offset i32)
        (param $static_offset i32)
        (result i32)

        (local $len i32)
        (local $o1 i32)
        (local $o2 i32)
        (local $matches i32)
        
        local.get $static_offset
        i32.load8_u
        local.set $len

        (local.set $matches (i32.const 0))
        (local.set $o1 (local.get $offset))
        ;; $static_offset is the offset of the number of bytes; $static_offset + 1 is the actual first byte to compare
        (local.set $o2 (i32.add (local.get $static_offset) (i32.const 1)))

        (block $block
            (loop $loop
                ;; check if the next bytes equal. If they aren't, break.
                (i32.load8_u (i32.add (local.get $o1) (local.get $matches)))
                (i32.load8_u (i32.add (local.get $o2) (local.get $matches)))
                i32.ne
                br_if $block

                ;; increment the matches by 1
                (local.set $matches (i32.add (local.get $matches) (i32.const 1)))

                ;; If the number of matches already equals the len, then we're done.
                local.get $matches
                local.get $len
                i32.eq
                br_if $block
                        
                ;; continue checking
                br $loop
            )
        )

        ;; if $matches == $len { $len } else { 0 }
        local.get $len
        i32.const 0
        (i32.eq (local.get $len) (local.get $matches))
        select
    )

    ;; get the number of bytes in the current line
    (func $line_length
        (param $offset i32)
        (result i32)

        (local $count i32)
        (local.set $count (i32.const 0))

        (loop $loop
            local.get $offset
            local.get $count
            i32.add

            (local.set $count (i32.add (local.get $count) (i32.const 1)))

            call $parse_newline
            i32.eqz
            br_if $loop
        )

        local.get $count
    )

    (func $find_first_number
        (param $offset i32)
        (result i32) ;; easy way out, we're going to *assume* it finds one, and return the value

        (local $current_offset i32)
        (local $r1 i32)
        (local $r2 i32)

        (local.set $current_offset (local.get $offset))

        (loop $loop
            local.get $current_offset
            call $parse_number
            local.set $r2
            local.set $r1

            (local.set $current_offset (i32.add (local.get $current_offset) (i32.const 1)))
            local.get $r2
            i32.eqz
            br_if $loop
        )

        local.get $r1
    )

    (func $find_last_number
        (param $offset i32)
        (result i32) ;; easy way out, we're going to *assume* it finds one, and return the value

        (local $current_offset i32)
        (local $r1 i32)
        (local $r2 i32)

        (local.set $current_offset (local.get $offset))

        (loop $loop
            local.get $current_offset
            call $parse_number
            local.set $r2
            local.set $r1

            (local.set $current_offset (i32.sub (local.get $current_offset) (i32.const 1)))
            local.get $r2
            i32.eqz
            br_if $loop
        )

        local.get $r1
    )

    ;; Parse an entire line from the input
    (func $parse_line
        (param $offset i32)
        (result i32 (; the value of the line ;))
        (result i32 (; how many bytes were parsed ;))

        (local $line_len_res i32)
        (local $first_digit i32)
        (local $last_digit i32)

        local.get $offset
        call $line_length
        local.set $line_len_res

        local.get $offset
        call $find_first_number
        local.set $first_digit

        local.get $offset
        local.get $line_len_res
        i32.add
        i32.const 1
        i32.sub
        call $find_last_number
        local.set $last_digit

        ;; sum
        (i32.add
            (i32.mul
                (local.get $first_digit)
                (i32.const 10)
            )
            (local.get $last_digit)
        )

        ;; parsed
        local.get $line_len_res
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