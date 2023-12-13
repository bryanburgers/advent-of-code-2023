(module
    (export "main" (func $main))
    (export "memory" (memory $mem))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))
    (import "dbg" "mem:24:sequence" (func $dbg.sequence (param i32) (result i32)))
    (import "dbg" "mem:20:line" (func $dbg.line (param i32) (result i32)))
    (import "dbg" "inspect:point" (func $dbg.point_helper (param i32 i32) (result i32 i32)))
    (import "dbg" "inspect:discriminator" (func $dbg.discriminator (param i32) (result i32)))
    (import "dbg" "inspect:unreachable_1" (func $dbg.unreachable_1))
    (import "dbg" "inspect:unreachable_2" (func $dbg.unreachable_2))
    (import "dbg" "inspect:size" (func $dbg.size (param i32 i32) (result i32 i32)))
    (import "dbg" "day10vis" (func $dbg.day10vis))

    (memory $mem 1)

    (global $input_len (mut i32) (i32.const 0))
    (global $width (mut i32) (i32.const 0))
    (global $height (mut i32) (i32.const 0))
    (global $starting_point (mut i64) (i64.const 0))
    (global $starting_direction (mut i32) (i32.const 0))

    (func $dbg.point (param $point i64) (result i64)
        (drop (drop (call $dbg.point_helper
            (call $point_x (local.get $point))
            (call $point_y (local.get $point))
        )))
        (local.get $point)
    )

    ;; our main function!
    (func $main (result i32)
        (local $point i64)
        (local $direction i32)
        (global.set $input_len
            (call $aoc.input
                (i32.const 0)))

        (global.set $width (call $calculate_width))
        (global.set $height (call $calculate_height))
        (global.set $starting_point (call $find_starting_point))
        (global.set $starting_direction (call $find_starting_direction))

        ;; Just make sure $find_starting_point is correct.
        (call $assert_on_starting_point (global.get $starting_point))

        ;; Replace the S with the byte it should be
        (i32.store8
            (call $point_to_offset (global.get $starting_point))
            (call $find_starting_piece))

        (local.set $point (global.get $starting_point))
        (local.set $direction (global.get $starting_direction))

        ;; (drop (call $dbg.point (local.get $point)))

        ;; Get off of the S.
        (call $point_in_direction (local.get $point) (local.get $direction))
        local.set $point

        (call $mark_point_as_visited (local.get $point))

        ;; (drop (call $dbg.point (local.get $point)))

        (loop $loop
            (call $move (local.get $point) (local.get $direction))
            local.set $direction
            local.set $point

            ;; (drop (call $dbg.point (local.get $point)))
            (call $mark_point_as_visited (local.get $point))

            (br_if $loop
                (i64.ne
                    (local.get $point)
                    (global.get $starting_point)))
        )

        (call $count_enclosed)

        (call $dbg.day10vis)
    )

    (func $calculate_width (result i32)
        (local $offset i32)
        (local $byte i32)
        (local.set $offset (i32.const 0))
        (block $break
            (loop $loop
                (local.set $byte
                    (i32.load8_u
                        (local.get $offset)))

                (br_if $break
                    (i32.eq
                        (local.get $byte)
                        (i32.const 0x0a (; "\n" ;))))

                (local.set $offset
                    (i32.add
                        (local.get $offset)
                        (i32.const 1)))
                
                br $loop
            )
        )
        
        local.get $offset
    )

    (func $calculate_height (result i32)
        (local $bytes_per_line_including_newline i32)
        (local.set $bytes_per_line_including_newline
            (i32.add
                (global.get $width)
                (i32.const 1)))

        (i32.div_u
            (global.get $input_len)
            (local.get $bytes_per_line_including_newline))
    )

    (func $find_starting_point (result i64)
        ;; I have everything solved. It's just busy work to write code to find
        ;; the starting point. So I looked at my input, and the starting point
        ;; is at (51, 58).
        ;;
        ;; The example2 starts at (4, 0)

        ;; Input
        (call $point
            (i32.const 51)
            (i32.const 58))
        
        ;; Example
        (call $point
            (i32.const 4)
            (i32.const 0))

        ;; If the width is > 21, then use the input. Otherwise use the example.
        (i32.gt_u
            (global.get $width)
            (i32.const 21))

        select
    )

    (func $assert_on_starting_point (param $point i64)
        (block $br
            (br_if $br
                (i32.eq
                    (call $char_at_point
                        (local.get $point))
                    (i32.const 0x53 (; "S" ;))))

            unreachable
        )
    )

    ;; Which piece should the S actually be?
    (func $find_starting_piece (result i32)
        ;; Again, being lazy.
        ;;
        ;; In the input, the S is actually an J.
        ;;
        ;; In example2, the S is actually a 7.

        ;; Input
        i32.const 0x4a
        
        ;; Example
        i32.const 0x37
        
        ;; If the width is > 21, then use the input. Otherwise use the example.
        (i32.gt_u
            (global.get $width)
            (i32.const 21))

        select
    )

    ;; Directions:
    ;; 0: W→E
    ;; 1: N→S
    ;; 2: E→W
    ;; 3: S→N

    (func $find_starting_direction (result i32)
        ;; Again, I'm lazy.
        ;;
        ;; The input starts going S→N or E→W.
        ;;
        ;; The example starts going N→S or E→W.
        
        ;; Both can start going E→W so that's our direction.
        (i32.const 2)
    )

    (func $mark_point_as_visited (param $point i64)
        (local $ptr i32)

        (local.set $ptr
            (call $point_to_offset
                (local.get $point)))

        (i32.store8
            (local.get $ptr)
            (i32.or
                (i32.load8_u
                    (local.get $ptr))
                (i32.const 0x80)))
    )

    (func $mark_point_as_inside (param $point i64)
        (local $ptr i32)

        (local.set $ptr
            (call $point_to_offset
                (local.get $point)))

        (i32.store8
            (local.get $ptr)
            (i32.const 0x01))
    )

    (func $point (param $x i32) (param $y i32) (result i64)
        (i64.or
            (i64.extend_i32_u (local.get $x))
            (i64.shl
                (i64.extend_i32_u (local.get $y))
                (i64.const 32)))
    )

    (func $point_x (param $point i64) (result i32)
        (i32.wrap_i64
            (local.get $point))
    )
    (func $point_y (param $point i64) (result i32)
        (i32.wrap_i64
            (i64.shr_u
                (local.get $point)
                (i64.const 32)))
    )

    (func $point_in_direction
        (param $point i64)
        (param $direction i32)
        (result i64)

        (local $result_x i32)
        (local $result_y i32)
        (local $x i32)
        (local $y i32)
        (local.set $x (call $point_x (local.get $point)))
        (local.set $y (call $point_y (local.get $point)))
    
        (block $block
            ;; 0: W→E
            (local.set $result_x (i32.add (local.get $x) (i32.const 1)))
            (local.set $result_y (i32.add (local.get $y) (i32.const 0)))
            (br_if $block
                (i32.eq
                    (local.get $direction)
                    (i32.const 0)))

            ;; 1: N→S
            (local.set $result_x (i32.add (local.get $x) (i32.const 0)))
            (local.set $result_y (i32.add (local.get $y) (i32.const 1)))
            (br_if $block
                (i32.eq
                    (local.get $direction)
                    (i32.const 1)))

            ;; 2: E→W
            (local.set $result_x (i32.add (local.get $x) (i32.const -1)))
            (local.set $result_y (i32.add (local.get $y) (i32.const 0)))
            (br_if $block
                (i32.eq
                    (local.get $direction)
                    (i32.const 2)))

            ;; 3: S→N
            (local.set $result_x (i32.add (local.get $x) (i32.const 0)))
            (local.set $result_y (i32.add (local.get $y) (i32.const -1)))
            (br_if $block
                (i32.eq
                    (local.get $direction)
                    (i32.const 3)))

            (call $dbg.unreachable_1)
            unreachable
        )

        (call $point (local.get $result_x) (local.get $result_y))
    )

    (func $char_at_point (param $point i64) (result i32)
        (i32.load8_u
            (call $point_to_offset
                (local.get $point)))
    )

    (func $point_to_offset (param $point i64) (result i32)
        (local $x i32)
        (local $y i32)
        (local $line_width_including_newline i32)

        (local.set $x (call $point_x (local.get $point)))
        (local.set $y (call $point_y (local.get $point)))

        (local.set $line_width_including_newline
            (i32.add
                (global.get $width)
                (i32.const 1)))
        
        (i32.add
            (i32.mul
                (local.get $y)
                (local.get $line_width_including_newline))
            (local.get $x))
    )

    (func $move
        (param $point i64)
        (param $direction i32)
        (result (;point;) i64)
        (result (;direction;) i32)

        (local $char i32)
        (local $discriminator i32 (; char in the least significant byte, direction in the next least ;))
        (local $result_point i64)
        (local $result_direction i32)

        (local.set $char
            (call $char_at_point
                (local.get $point)))

        ;; if the char has already been marked as visited, unmark it.
        (local.set $char
            (i32.and
                (local.get $char)
                (i32.const 0x7f)))

        (local.set $discriminator
            (i32.or
                (local.get $char)
                (i32.shl
                    (local.get $direction)
                    (i32.const 8))))

        (block $block
            ;; -: 0x2d
            ;; |: 0x7c
            ;; L: 0x4c
            ;; J: 0x4a
            ;; F: 0x46
            ;; 7: 0x37

            ;; 0: W→E
            ;; 1: N→S
            ;; 2: E→W
            ;; 3: S→N

            ;; | + N→S ⇒ N→S
            (local.set $result_direction (i32.const 1))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x017c)))
            ;; | + S→N ⇒ S→N
            (local.set $result_direction (i32.const 3))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x037c)))
            ;; - + W→E ⇒ W→E
            (local.set $result_direction (i32.const 0))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x002d)))
            ;; - + E→W ⇒ E→W
            (local.set $result_direction (i32.const 2))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x022d)))
            ;; L + N→S ⇒ W→E
            (local.set $result_direction (i32.const 0))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x014c)))
            ;; L + E→W ⇒ S→N
            (local.set $result_direction (i32.const 3))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x024c)))
            ;; J + N→S ⇒ E→W
            (local.set $result_direction (i32.const 2))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x014a)))
            ;; J + W→E ⇒ S→N
            (local.set $result_direction (i32.const 3))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x004a)))
            ;; F + S→N ⇒ W→E
            (local.set $result_direction (i32.const 0))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x0346)))
            ;; F + E→W ⇒ N→S
            (local.set $result_direction (i32.const 1))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x0246)))
            ;; 7 + S→N ⇒ E→W
            (local.set $result_direction (i32.const 2))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x0337)))
            ;; 7 + W→E ⇒ N→S
            (local.set $result_direction (i32.const 1))
            (br_if $block (i32.eq (local.get $discriminator) (i32.const 0x0037)))

            (call $dbg.unreachable_2)
            unreachable
        )

        (local.set $result_point
            (call $point_in_direction
                (local.get $point)
                (local.get $result_direction)))

        local.get $result_point
        local.get $result_direction
    )

    (func $count_enclosed (result i32)
        (local $row i32)
        (local $sum i32)
        (loop $loop
            (local.set $sum
                (i32.add
                    (local.get $sum)
                    (call $count_enclosed_row (local.get $row))))

            (local.set $row
                (i32.add
                    (local.get $row)
                    (i32.const 1)))

            (br_if $loop
                (i32.lt_u
                    (local.get $row)
                    (global.get $height)))
        )
        local.get $sum
    )

    (func $count_enclosed_row (param $y i32) (result i32)
        (local $x i32)
        (local $byte i32)
        (local $toggle i32 (; 0 if outside the loop, 1 if inside the loop ;))
        (local $start_byte i32 (; if we're on an edge, which byte did we start on; 0 if we're not on an edge ;))
        (local $count i32)

        ;; To switch the toggle
        ;; (local.set $toggle (i32.xor (local.get $toggle) (i32.const 0x1))

        (loop $loop
            (local.set $byte
                (call $char_at_point
                    (call $point
                        (local.get $x)
                        (local.get $y))))

            ;; if the point is a visited point...
            (if (i32.and (local.get $byte) (i32.const 0x80))
                (then
                    ;; The point is a visited point.

                    ;; If it's a |, then toggle.
                    (if (i32.eq (local.get $byte) (i32.const 0xfc))
                        (then
                            (local.set $toggle (i32.xor (local.get $toggle) (i32.const 0x1)))
                        )
                    )

                    ;; If it's a -, then do nothing.

                    ;; If it's an F, then maybe start a toggle
                    (if (i32.eq (local.get $byte) (i32.const 0xc6))
                        (then (local.set $start_byte (i32.const 0xc6)))
                    )
                    ;; If it's an L, then maybe start a toggle
                    (if (i32.eq (local.get $byte) (i32.const 0xcc))
                        (then (local.set $start_byte (i32.const 0xcc)))
                    )

                    ;; If it's a 7, then only complete the toggle if we started on an L
                    (if (i32.and
                            (i32.eq (local.get $byte) (i32.const 0xb7))
                            (i32.eq (local.get $start_byte) (i32.const 0xcc)))
                        (then
                            (local.set $toggle (i32.xor (local.get $toggle) (i32.const 0x1)))
                        )
                    )
                    ;; If it's a J, then only complete the toggle if we started on an F
                    (if (i32.and
                            (i32.eq (local.get $byte) (i32.const 0xca))
                            (i32.eq (local.get $start_byte) (i32.const 0xc6)))
                        (then
                            (local.set $toggle (i32.xor (local.get $toggle) (i32.const 0x1)))
                        )
                    )
                )
                (else
                    ;; Otherwise increase the count if we're toggled
                    (local.set $count
                        (i32.add
                            (local.get $count)
                            (local.get $toggle)))

                    (if (local.get $toggle)
                        (then
                            (call $mark_point_as_inside (call $point (local.get $x) (local.get $y)))
                        )
                    )
                )
            )

            (local.set $x
                (i32.add
                    (local.get $x)
                    (i32.const 1)))

            (br_if $loop
                (i32.lt_u
                    (local.get $x)
                    (global.get $width)))
        )
        local.get $count
    )
)