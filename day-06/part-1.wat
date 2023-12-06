(module    
    (export "main" (func $main))
    
    (memory $memory 1)
    (data (i32.const 0) "\02\00")

    (func $main
        (result i32 i32)

        ;; Parsing the actual input seems like a waste. We'll just hardcode
        ;; the values.
        
        ;; Example
        ;; Time:      7  15   30
        ;; Distance:  9  40  200

        i32.const 1
        (call $solve (i32.const 7) (i32.const 9))
        i32.mul
        (call $solve (i32.const 15) (i32.const 40))
        i32.mul
        (call $solve (i32.const 30) (i32.const 200))
        i32.mul

        ;; Input
        ;; Time:        48     93     84     66
        ;; Distance:   261   1192   1019   1063

        i32.const 1
        (call $solve (i32.const 48) (i32.const 261))
        i32.mul
        (call $solve (i32.const 93) (i32.const 1192))
        i32.mul
        (call $solve (i32.const 84) (i32.const 1019))
        i32.mul
        (call $solve (i32.const 66) (i32.const 1063))
        i32.mul
    )

    (func $solve
        (param $total_time i32)
        (param $best_distance i32)
        (result (; ways to win ;) i32)

        (local $loop_var i32)
        (local $ways_to_win i32)
        (local.set $loop_var (i32.const 0))
        (local.set $ways_to_win (i32.const 0))

        (block $block
            (loop $loop
                local.get $total_time
                local.get $loop_var
                call $calc_distance
                local.get $best_distance
                i32.gt_u

                (if
                    (then
                        local.get $ways_to_win
                        i32.const 1
                        i32.add
                        local.set $ways_to_win
                    )
                )

                local.get $loop_var
                local.get $total_time
                i32.ge_u
                br_if $block

                local.get $loop_var
                i32.const 1
                i32.add
                local.set $loop_var
                br $loop
            )
        )

        local.get $ways_to_win
    )

    (func $calc_distance
        (param $total_time i32)
        (param $hold_time i32)
        (result (; distance travelled ;) i32)

        local.get $total_time
        local.get $hold_time
        i32.sub
        local.get $hold_time
        i32.mul
    )
)