use anyhow::Result;
use ethers::utils::{hex, keccak256};

/// Parses a hex string into bytes and hashes it using the Keccak-256 algorithm.
///
/// # Arguments
/// * `input` - The input string to hash. Must be a hex string.
///
/// # Returns
/// * `Result<[u8; 32]>` - Ok if parsing the operation was successful, Err otherwise.
pub fn parse_and_hash(input: String) -> Result<[u8; 32]> {
    let bytes = hex::decode(input)?;
    Ok(keccak256(bytes))
}

/// Encodes a byte slice into a hex string.
///
/// # Arguments
/// * `input` - The input byte slice to encode.
///
/// # Returns
/// * `String` - The encoded hex string.
pub fn encode_hex<T: AsRef<[u8]>>(input: T) -> String {
    hex::encode(input)
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_parse_and_hash() {
        let results = [
            (
                "010101".to_string(),
                "7ad37e9ae69046be83354f8de5e8b4814d21075a11ce84f5e52f89733145e87c",
            ),
            (
                "c0ffee".to_string(),
                "7924f890e12acdf516d6278e342cd34550e3bafe0a3dec1b9c2c3e991733711a",
            ),
            (
                "deadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEADdeadDEAD".to_string(),
                "3533db3dae8fa9a318fccd9089e31a992cdbd873fd4bd85df870a78494b1762c"
            )
        ];

        for (input, expected) in results {
            let digest = parse_and_hash(input).unwrap();
            assert_eq!(hex::encode(digest), expected);
        }
    }
}
