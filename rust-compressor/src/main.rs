
use clap::{Parser, Subcommand};
use std::fs;
use std::io::{self, Read, Write};
use anyhow::{Context, Result};

mod rle;
mod lz;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Compress {
        #[arg(short, long)]
        algorithm: String,
        input: String,
        output: String,
    },
    Decompress {
        #[arg(short, long)]
        algorithm: String,
        input: String,
        output: String,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Compress { algorithm, input, output } => {
            let data = fs::read(input)
                .context("Failed to read input file")?;
            
            let compressed = match algorithm.as_str() {
                "rle" => rle::compress(&data),
                "lz" => lz::compress(&data),
                _ => anyhow::bail!("Unknown algorithm"),
            };

            fs::write(output, compressed)
                .context("Failed to write output file")?;
        }
        Commands::Decompress { algorithm, input, output } => {
            let data = fs::read(input)
                .context("Failed to read input file")?;
            
            let decompressed = match algorithm.as_str() {
                "rle" => rle::decompress(&data),
                "lz" => lz::decompress(&data),
                _ => anyhow::bail!("Unknown algorithm"),
            };

            fs::write(output, decompressed)
                .context("Failed to write output file")?;
        }
    }

    Ok(())
}
