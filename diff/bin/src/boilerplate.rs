use anyhow::{anyhow, Result};
use clap::{ArgAction, Parser};
use tracing::Level;

/// A simple clap boilerplate
#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    /// Verbosity level (0-4)
    #[arg(long, short, help = "Verbosity level (0-4)", action = ArgAction::Count)]
    v: u8,

    /// An example flag
    #[arg(short, long)]
    in_bytes: String,
}

fn main() -> Result<()> {
    // Parse the command arguments
    let Args { v, in_bytes } = Args::parse();

    // Initialize the tracing subscriber
    init_tracing_subscriber(v)?;

    tracing::debug!(target: "boilerplate_cli", "Attempting to hash input bytes: {:?}", in_bytes);
    let digest = example_lib::parse_and_hash(in_bytes)?;
    println!(
        "Keccak256 digest of input: 0x{}",
        example_lib::encode_hex(digest)
    );

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
