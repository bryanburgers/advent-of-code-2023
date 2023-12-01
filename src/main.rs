use std::path::PathBuf;

use clap::Parser;
use wasmtime::{Caller, Config, Engine, Extern, Linker, Module, Store, Val};

#[derive(Parser)]
pub struct Args {
    /// The location of the wasm or the wat to run
    #[clap(value_name = "FILE")]
    code: PathBuf,
    /// The location of the problem input
    #[clap(value_name = "FILE")]
    input: PathBuf,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();
    // Our hand-written file.
    let code = std::fs::read(args.code)?;
    let input = std::fs::read(args.input)?;

    // A whole bunch of wasmtime initialization.
    let config = Config::new();
    let engine = Engine::new(&config)?;
    let module = Module::new(&engine, code)?;
    let mut linker = Linker::new(&engine);

    linker.func_wrap("aoc", "input_len", |caller: Caller<'_, Vec<u8>>| -> i32 {
        caller.data().len() as i32
    })?;
    linker.func_wrap(
        "aoc",
        "input",
        |mut caller: Caller<'_, Vec<u8>>, offset: u32| -> anyhow::Result<i32> {
            let Some(Extern::Memory(memory)) = caller.get_export("memory") else {
                anyhow::bail!("no memory with name `memory`");
            };

            let (memory, data) = memory.data_and_store_mut(&mut caller);
            let data_len = data.len();

            let segment = &mut memory[offset as usize..][..data_len];
            if segment.len() != data_len {
                anyhow::bail!("not enough space to write input");
            }

            segment.clone_from_slice(data);

            Ok(data_len as i32)
        },
    )?;
    linker.func_wrap("dbg", "panic", |val: i32| -> anyhow::Result<()> {
        anyhow::bail!("panic with code {val:08x}");
    })?;
    linker.func_wrap("dbg", "i32", |val: i32| {
        println!("{val} ({val:08x})");
    })?;
    linker.func_wrap(
        "dbg",
        "mem",
        |mut caller: Caller<'_, Vec<u8>>, ptr: i32, len: i32| {
            let Some(Extern::Memory(memory)) = caller.get_export("memory") else {
                return;
            };

            let memory = memory.data(&caller);
            let bytes = &memory[ptr as usize..][..len as usize];
            let mut is_first = true;
            print!("data at {ptr:08x}: ");
            for byte in bytes {
                if is_first {
                    is_first = false;
                    print!("{byte:02x}");
                } else {
                    print!(" {byte:02x}");
                }
            }
            println!();
        },
    )?;

    let mut store = Store::new(&engine, input);
    let instance = linker.instantiate(&mut store, &module)?;

    // Get the exported "main" function. If we knew exactly what type the main function was,
    // `.get_typed_func` would be super valuable. But while playing around, I'm going to allow
    // the "main" function to return any values it wants to.
    let func = instance
        .get_func(&mut store, "main")
        .ok_or("no main func")?;
    // Initialize a vec to hold all of the return values from "main".
    let func_ty = func.ty(&mut store);
    let mut results = vec![wasmtime::Val::I32(0); func_ty.results().len()];
    // Call main...
    func.call(&mut store, &[], &mut results)?;

    // And output all of its return values.
    let output = results
        .into_iter()
        .map(|val| match val {
            Val::I32(i32) => i32.to_string(),
            Val::I64(i64) => i64.to_string(),
            Val::F32(f32) => f32.to_string(),
            Val::F64(f64) => f64.to_string(),
            Val::V128(v128) => format!("{v128:?}"),
            Val::FuncRef(_) => String::from("<funcref>"),
            Val::ExternRef(_) => String::from("<externref>"),
        })
        .collect::<Vec<String>>()
        .join(" ");
    println!("{output}");

    Ok(())
}
