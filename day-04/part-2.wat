(module    
    (export "main" (func $main))
    (export "memory" (memory $memory))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))
    (import "dbg" "inspect:i32" (func $dbg.i32 (param i32) (result i32)))
    (import "dbg" "inspect:card_id matches" (func $dbg.cardid_matches (param i32 i32) (result i32 i32)))
    (import "dbg" "inspect:incrementing   " (func $dbg.incrementing (param i32 i32) (result i32 i32)))

    (memory $memory 1)

    (global $extrabook_start (mut i32) (i32.const 0))

    (func $main
        (result i32)
        (local $input_len i32)
        (local $parsed i32)
        (local $sum i32)
        (local $cards i32)
        (local $loop_matches i32)
        
        call $aoc.input_len
        local.tee $input_len
        i32.const 1000
        i32.add
        global.set $extrabook_start

        i32.const 0
        call $aoc.input
        drop
        
        (local.set $parsed (i32.const 0))
        (local.set $sum (i32.const 0))
        (local.set $cards (i32.const 0))

        (loop $loop
            local.get $cards
            i32.const 1
            i32.add
            local.set $cards

            local.get $parsed
            call $parse_line
            local.get $parsed
            i32.add
            local.set $parsed

            local.set $loop_matches

            local.get $cards
            local.get $loop_matches
            call $extrabook_increment

            local.get $parsed
            local.get $input_len
            i32.lt_u
            br_if $loop
        )

        local.get $cards
        call $extrabook_total
    )

    (func $parse_line
        (param $offset i32)
        (result i32 (; number of matches ;) )
        (result i32 (; bytes parsed ;) )

        (local $cur_offset i32)
        (local $parse_trimmed_number_value i32)
        (local $parse_trimmed_number_bytes i32)
        (local $winning_numbers v128)
        (local $owned_numbers v128)

        (local.set $winning_numbers (v128.const i64x2 0 0))
        (local.set $owned_numbers (v128.const i64x2 0 0))
        
        ;; skip over the 4 bytes in "Card"
        local.get $offset
        i32.const 4
        i32.add
        local.tee $cur_offset

        ;; parse the card number. We don't care about the result, but we do need
        ;; to know how many bytes to skip.
        call $parse_trimmed_number
        local.get $cur_offset
        i32.add
        local.set $cur_offset
        drop ;; drop the returned value.

        ;; skip over the ':' in "Card 17:"
        local.get $cur_offset
        i32.const 1
        i32.add
        local.set $cur_offset

        ;; parse the winning numbers
        (block $block
            (loop $loop
                local.get $cur_offset
                call $parse_trimmed_number
                local.set $parse_trimmed_number_bytes
                local.set $parse_trimmed_number_value

                ;; if no number was parsed, we're done.
                local.get $parse_trimmed_number_bytes
                i32.eqz
                br_if $block

                local.get $cur_offset
                local.get $parse_trimmed_number_bytes
                i32.add
                local.set $cur_offset

                local.get $winning_numbers
                local.get $parse_trimmed_number_value
                call $cardset_add
                local.set $winning_numbers
                
                br $loop
            )
        )

        ;; parse the pipe. Really we should check this, but I guess we trust
        ;; the input.
        local.get $cur_offset
        call $parse_pipe
        local.get $cur_offset
        i32.add
        local.set $cur_offset

        ;; parse the owned numbers
        (block $block
            (loop $loop
                local.get $cur_offset
                call $parse_trimmed_number
                local.set $parse_trimmed_number_bytes
                local.set $parse_trimmed_number_value

                ;; if no number was parsed, we're done.
                local.get $parse_trimmed_number_bytes
                i32.eqz
                br_if $block

                local.get $cur_offset
                local.get $parse_trimmed_number_bytes
                i32.add
                local.set $cur_offset

                local.get $owned_numbers
                local.get $parse_trimmed_number_value
                call $cardset_add
                local.set $owned_numbers
                
                br $loop
            )
        )

        ;; parse the newline. Really we should check this, but I guess we trust
        ;; the input.
        local.get $cur_offset
        call $parse_newline
        local.get $cur_offset
        i32.add
        local.set $cur_offset

        ;; Calculate the value of the line
        local.get $winning_numbers
        local.get $owned_numbers
        call $cardscore

        ;; and how many bytes were parsed
        local.get $cur_offset
        local.get $offset
        i32.sub
    )
    
    (func $extrabook_increment
        (param $card_id i32)
        (param $matches i32)

        (local $how_much_to_increment i32)
        (local $counter i32)
        (local $loop_card_id i32)
        (local $loop_card_offset i32)

        ;; local.get $card_id
        ;; local.get $matches
        ;; call $dbg.cardid_matches
        ;; drop
        ;; drop

        ;; get current number of extra cards for this card ID
        local.get $card_id
        call $extrabook_card_offset
        i32.load
        ;; and then get the total number of cards for this ID (including the default one)
        i32.const 1
        i32.add
        local.set $how_much_to_increment

        (local.set $counter (i32.const 1))

        (block $block
            (loop $loop
                ;; if counter > matches then break
                local.get $counter
                local.get $matches
                i32.gt_u
                br_if $block

                local.get $counter
                local.get $card_id
                i32.add
                local.set $loop_card_id

                local.get $loop_card_id
                call $extrabook_card_offset
                local.set $loop_card_offset

                ;; local.get $loop_card_id
                ;; local.get $how_much_to_increment
                ;; call $dbg.incrementing
                ;; drop
                ;; drop

                ;; increment the number of extra cards
                local.get $loop_card_offset
                local.get $loop_card_offset
                i32.load
                local.get $how_much_to_increment
                i32.add
                i32.store

                ;; increemnt counter
                local.get $counter
                i32.const 1
                i32.add
                local.set $counter

                br $loop
            )
        )
    )

    (func $extrabook_card_offset
        (param $card_id i32)
        (result i32 (; memory offset ;) )

        global.get $extrabook_start
        local.get $card_id
        i32.const 4 ;; 4 bytes per card, sure.
        i32.mul
        i32.add
    )

    (func $extrabook_total
        (param $cards i32)
        (result i32 (; total cards ;))

        (local $sum i32)
        (local $counter i32)

        (loop $loop
            local.get $counter
            i32.const 1
            i32.add
            local.set $counter

            ;; get the number of extra cards
            local.get $counter
            ;; call $dbg.i32
            call $extrabook_card_offset
            i32.load
            ;; and then get the total number of cards for this ID (including the default one)
            i32.const 1
            i32.add
            ;; call $dbg.i32
            local.get $sum
            i32.add
            local.set $sum

            local.get $counter
            local.get $cards
            i32.lt_u
            br_if $loop
        )

        local.get $sum
    )

    (func $cardset_make (result v128)
        v128.const i64x2 0 0
    )

    (func $cardset_add (param $cardset v128) (param $value i32) (result v128)
        local.get $value
        i32.const 64
        i32.ge_u

        (if (result v128)
            (then
                ;; $value >= 64

                v128.const i64x2 0 0

                i64.const 1
                local.get $value
                i32.const 64
                i32.sub
                i64.extend_i32_u
                i64.shl

                i64x2.replace_lane 1

                local.get $cardset
                v128.or
            )
            (else
                ;; $value < 64

                v128.const i64x2 0 0

                i64.const 1
                local.get $value
                i64.extend_i32_u
                i64.shl

                i64x2.replace_lane 0

                local.get $cardset
                v128.or
            )
        )
    )

    (func $cardscore (param $a v128) (param $b v128) (result i32)
        (local $anded v128)
        (local $popcnt i32)

        local.get $a
        local.get $b
        v128.and
        local.set $anded

        local.get $anded
        i32x4.extract_lane 0
        i32.popcnt

        local.get $anded
        i32x4.extract_lane 1
        i32.popcnt

        local.get $anded
        i32x4.extract_lane 2
        i32.popcnt

        local.get $anded
        i32x4.extract_lane 3
        i32.popcnt

        i32.add
        i32.add
        i32.add
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

    (func $parse_number (param $address i32) (result (; number ;) i32 (; bytes parsed ;) i32)
        (local $bytes_parsed i32)
        (local $current_address i32)
        (local $parse_digit_success i32)
        (local $parse_digit_value i32)
        (local $number i32)

        ;; initialize $number to 0
        i32.const 0
        local.set $number
        ;; initialize $bytes_parsed to 0
        i32.const 0
        local.set $bytes_parsed
        ;; initialize $current_address to the input parameter $address
        local.get $address
        local.set $current_address

        (block $outer
            (loop $inner

                local.get $current_address
                call $parse_digit
                local.set $parse_digit_success
                local.set $parse_digit_value

                local.get $parse_digit_success
                (if
                    (then
                        ;; increment the number of bytes parsed
                        local.get $bytes_parsed
                        i32.const 1
                        i32.add
                        local.set $bytes_parsed                        

                        ;; $number = $number * 10 + $parse_digit_value
                        local.get $number
                        i32.const 10
                        i32.mul
                        local.get $parse_digit_value
                        i32.add
                        local.set $number
                    )
                    (else
                        ;; break; exit the loop
                        br $outer
                    )
                )

                ;; increment the $current_address
                local.get $current_address
                i32.const 1
                i32.add
                local.set $current_address

                ;; and parse the next digit
                br $inner
            )
        )

        local.get $number
        local.get $bytes_parsed
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

    (func $parse_pipe
        (param $offset i32)
        (result i32 (; 1 if successful, 0 if not ;))

        local.get $offset
        i32.load8_u
        i32.const 0x7c ;; "|"
        i32.eq
    )

    (func $parse_multiple_spaces
        (param $offset i32)
        (result (; bytes parsed ;) i32)

        (local $parsed i32)
        (local.set $parsed (i32.const 0))

        (block $block
            (loop $loop
                local.get $offset
                local.get $parsed
                i32.add
                call $parse_space

                i32.eqz
                br_if $block

                local.get $parsed
                i32.const 1
                i32.add
                local.set $parsed

                br $loop
            )
        )

        local.get $parsed
    )

    (func $parse_trimmed_number
        (param $offset i32)
        (result (; number ;) i32)
        (result (; bytes parsed ;) i32)

        (local $total_parsed i32)
        (local $result i32)
        (local $parsed i32)

        (block $br
            ;; parse initial whitespace
            local.get $offset
            call $parse_multiple_spaces
            local.set $total_parsed

            ;; parse number
            local.get $offset
            local.get $total_parsed
            i32.add
            call $parse_number
            local.set $parsed
            local.set $result

            ;; check if we actually parsed a number
            local.get $result
            i32.const 0
            i32.gt_u
            (if
                (then
                    local.get $total_parsed
                    local.get $parsed
                    i32.add
                    local.set $total_parsed
                )
                (else
                    (local.set $total_parsed (i32.const 0))
                    (local.set $result (i32.const 0))
                    br $br
                )
            )

            ;; parse trailing whitespace
            local.get $offset
            local.get $total_parsed
            i32.add
            call $parse_multiple_spaces
            local.get $total_parsed
            i32.add
            local.set $total_parsed
        )

        local.get $result
        local.get $total_parsed
    )
)