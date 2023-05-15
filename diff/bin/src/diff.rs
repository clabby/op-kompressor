use anyhow::{anyhow, Result};
use clap::{ArgAction, Parser};
use tracing::Level;

/// The command line arguments for the `diff` binary
#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    /// Verbosity level (0-4)
    #[arg(long, short, help = "Verbosity level (0-4)", action = ArgAction::Count)]
    v: u8,

    /// Bytes to compress or decompress
    #[arg(short, long)]
    in_bytes: String,

    /// Mode of compression or decompression
    #[arg(short, long)]
    mode: Mode,
}

/// The mode of compression or decompression
#[derive(Debug, Clone)]
enum Mode {
    ZeroKompress,
    ZeroDekompress,
}

impl From<String> for Mode {
    fn from(s: String) -> Self {
        match s.as_str() {
            "zero-kompress" => Mode::ZeroKompress,
            "zero-dekompress" => Mode::ZeroDekompress,
            _ => panic!("Invalid mode"),
        }
    }
}

fn main() -> Result<()> {
    // Parse the command arguments
    let Args { v, in_bytes, mode } = Args::parse();

    // Initialize the tracing subscriber
    init_tracing_subscriber(v)?;

    // Trim the leading "0x" if it exists.
    let in_bytes = in_bytes.trim_start_matches("0x").to_string();

    match mode {
        Mode::ZeroKompress => {
            tracing::info!(target: "diff_cli", "Attempting to ZeroKompress input bytes: {:?}", in_bytes);
            print!("{}", zero_kompressor::zero_kompress(in_bytes)?);
        }
        Mode::ZeroDekompress => {
            tracing::info!(target: "diff_cli", "Attempting to ZeroDekompress input bytes: {:?}", in_bytes);
            print!("{}", zero_kompressor::zero_dekompress(in_bytes)?);
        }
    }

    Ok(())
}

/// Initializes the tracing subscriber
///
/// # Arguments
/// * `verbosity_level` - The verbosity level (0-4)
///
/// # Returns
/// * `Result<()>` - Ok if successful, Err otherwise.
fn init_tracing_subscriber(verbosity_level: u8) -> Result<()> {
    let subscriber = tracing_subscriber::fmt()
        .with_max_level(match verbosity_level {
            0 => Level::ERROR,
            1 => Level::WARN,
            2 => Level::INFO,
            3 => Level::DEBUG,
            _ => Level::TRACE,
        })
        .finish();
    tracing::subscriber::set_global_default(subscriber).map_err(|e| anyhow!(e))
}
