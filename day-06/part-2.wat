(module    
    (export "main" (func $main))

    (func $main
        (result i64 i64)

        ;; Parsing the actual input seems like a waste. We'll just hardcode
        ;; the values.
        
        ;; Example
        ;; Time:      7  15   30
        ;; Distance:  9  40  200

        (call $solve (i64.const 71530) (i64.const 940200))

        ;; Input
        ;; Time:        48     93     84     66
        ;; Distance:   261   1192   1019   1063

        (call $solve (i64.const 48938466) (i64.const 261119210191063))        
    )

    (func $solve
        (param $total_time i64)
        (param $best_distance i64)
        (result (; ways to win ;) i64)

        (local $loop_var i64)
        (local $ways_to_win i64)
        (local.set $loop_var (i64.const 0))
        (local.set $ways_to_win (i64.const 0))

        (block $block
            (loop $loop
                local.get $total_time
                local.get $loop_var
                call $calc_distance
                local.get $best_distance
                i64.gt_u

                (if
                    (then
                        local.get $ways_to_win
                        i64.const 1
                        i64.add
                        local.set $ways_to_win
                    )
                )

                local.get $loop_var
                local.get $total_time
                i64.ge_u
                br_if $block

                local.get $loop_var
                i64.const 1
                i64.add
                local.set $loop_var
                br $loop
            )
        )

        local.get $ways_to_win
    )

    (func $calc_distance
        (param $total_time i64)
        (param $hold_time i64)
        (result (; distance travelled ;) i64)

        local.get $total_time
        local.get $hold_time
        i64.sub
        local.get $hold_time
        i64.mul
    )
)