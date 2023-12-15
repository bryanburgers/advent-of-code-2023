(module
    (export "main" (func $main))
    (export "memory" (memory $mem))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))
    (import "dbg" "inspect:h" (func $dbg.h (param i32) (result i32)))

    (memory $mem 1)

    (global $input_len (mut i32) (i32.const 0))

    ;; our main function!
    (func $main (result i32)
        (local $offset i32)
        (local $len i32)
        (local $sum i32)
        (local $h i32)
        
        (global.set $input_len
            (call $aoc.input
                (i32.const 0)))

        (loop $loop
            (local.set $len
                (call $parse_instruction
                    (local.get $offset)))

            (local.set $h
                (call $hash
                    (local.get $offset)
                    (local.get $len)))

            (;drop (call $dbg.h (local.get $h));)

            (local.set $sum
                (i32.add
                    (local.get $sum)
                    (local.get $h)))

            (local.set $offset
                (i32.add
                    (i32.add
                        (local.get $offset)
                        (local.get $len))
                    (i32.const (; skip the comma, too ;) 1)))

            (br_if $loop
                (i32.lt_u
                    (local.get $offset)
                    (global.get $input_len)))
        )

        (local.get $sum)
    )

    (func $parse_instruction (param $offset i32) (result (; len ;) i32)
        (local $current_offset i32)
        (local $byte i32)
        (local.set $current_offset (local.get $offset))
        
        (block $block
            (loop $loop
                (local.set $byte
                    (i32.load8_u
                        (local.get $current_offset)))

                (br_if $block
                    (i32.eq
                        (local.get $byte)
                        (i32.const 0x2c)))

                (br_if $block
                    (i32.eq
                        (local.get $byte)
                        (i32.const 0x00)))

                (local.set $current_offset
                    (i32.add
                        (local.get $current_offset)
                        (i32.const 1)))
                
                br $loop
            )
        )
        
        (i32.sub
            (local.get $current_offset)
            (local.get $offset))
    )

    (func $hash (param $offset i32) (param $len i32) (result i32)
        (local $h i32)
        (local $end_ptr i32)
        (local $ptr i32)
        (local.set $ptr (local.get $offset))
        (local.set $end_ptr (i32.add (local.get $offset) (local.get $len)))

        (block $break
            (loop $continue
                (br_if $break
                    (i32.ge_u
                        (local.get $ptr)
                        (local.get $end_ptr)))

                (local.set $h
                    (i32.add
                        (local.get $h)
                        (i32.load8_u
                            (local.get $ptr))))

                (local.set $h
                    (i32.mul
                        (local.get $h)
                        (i32.const 17)))

                (local.set $h
                    (i32.and
                        (local.get $h)
                        (i32.const 0xff)))

                (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))
                (br $continue)
            )
        )
        
        local.get $h
    )
)