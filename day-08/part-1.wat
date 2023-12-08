(module
    (export "main" (func $main))
    (export "memory" (memory $mem))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))

    (memory $mem 1)

    (global $AAA i32 (i32.const 0x00414141))
    (global $ZZZ i32 (i32.const 0x005a5a5a))
    (global $start_of_network (mut i32) (i32.const 0))
    (global $input_len (mut i32) (i32.const 0))

    ;; our main function!
    (func $main (result i32)
        (local $node i32)
        (local $steps i32)
        (local $network_item_ptr i32)

        (global.set $input_len
            (call $aoc.input
                (i32.const 0)))
        
        (global.set $start_of_network
            (call $find_start_of_network))

        (local.set $node (global.get $AAA))

        (block $break
            (loop $continue
                ;; if we're on the ZZZ, we're done.
                (br_if $break
                    (i32.eq
                        (local.get $node)
                        (global.get $ZZZ)))

                (local.set $network_item_ptr
                    (call $find_network_item
                        (local.get $node)))

                (local.set $node
                    (call $network_item_next
                        (local.get $network_item_ptr)
                        (call $next_dir)))

                (local.set $steps
                    (i32.add
                        (local.get $steps)
                        (i32.const 1)))

                br $continue
            )
        )

        local.get $steps
    )

    (func $is_l (param $ptr i32) (result i32)
        local.get $ptr
        i32.load8_u
        i32.const 0x4c ;; "L"
        i32.eq
    )

    (func $is_r (param $ptr i32) (result i32)
        local.get $ptr
        i32.load8_u
        i32.const 0x52 ;; "R"
        i32.eq
    )

    ;; Iterator that continuously returns L (0) or R (1). If it reaches the end
    ;; of the input, it loops around.
    (global $next_dir.ptr (mut i32) (i32.const 0))
    (func $next_dir (result i32)
        (local $ret i32)

        (block $outer
            (block $inner
                (local.set $ret (i32.const 0))
                (call $is_l (global.get $next_dir.ptr))
                br_if $inner

                (local.set $ret (i32.const 1))
                (call $is_r (global.get $next_dir.ptr))
                br_if $inner

                (global.set $next_dir.ptr (i32.const 0))
                (local.set $ret (call $next_dir))
                br $outer
            )

            (global.set $next_dir.ptr
                (i32.add
                    (global.get $next_dir.ptr)
                    (i32.const 1)))
        )

        local.get $ret
    )

    ;; Find the ptr to the start of the network
    (func $find_start_of_network (result i32)
        (local $ptr i32)

        (loop $loop
            (call $is_l (local.get $ptr))
            (call $is_r (local.get $ptr))
            i32.or
            (if
                (then
                    (local.set $ptr
                        (i32.add
                            (local.get $ptr)
                            (i32.const 1)))
                    br $loop
                )
            )

            ;; it's not an L or an R.
            
            ;; account for both trailing newlines
            (local.set $ptr
                (i32.add
                    (local.get $ptr)
                    (i32.const 2)))

            ;; and fall through
        )

        local.get $ptr
    )

    ;; nodes are represented as 3 bytes. We can get the node ID from a ptr of
    ;; memory by loading 4 bytes (an i32) and masking off the fourth (most
    ;; significant) byte.
    (func $node (param $ptr i32) (result i32)
        (i32.load (local.get $ptr))
        (i32.const 0x00ffffff)
        i32.and
    )

    (func $find_network_item
        (param $node i32)
        (result (; ptr to network item ;) i32)

        (local $ptr i32)
        (local.set $ptr (global.get $start_of_network))

        (block $block
            (loop $loop
                (call $node (local.get $ptr))
                (local.get $node)
                i32.eq
                br_if $block

                (local.set $ptr
                    (i32.add
                        (local.get $ptr)
                        (i32.const 17))) ;; 17 is length of a network item

                global.get $input_len
                local.get $ptr
                i32.gt_u
                br_if $loop

                unreachable ;; panic! We should run past the end of the input
            )
        )

        (local.get $ptr)
    )

    (func $network_item_next
        (param $ptr i32)
        (param $l_or_r i32)
        (result (; node ;) i32)

        (local $offset i32)

        (local.set $offset
            (select
                (i32.const 12)
                (i32.const 7)
                (local.get $l_or_r)
            )
        )

        (call $node
            (i32.add
                (local.get $ptr)
                (local.get $offset)))
    )
)