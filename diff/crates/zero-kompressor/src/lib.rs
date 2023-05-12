use anyhow::Result;
use ethers::utils::hex;

/// ZeroKompress a byte array
/// Run Length Encode only zeros in the byte array
/// Inefficient, but eh, it's for differential testing. Clean up later.
pub fn zero_kompress(bytes: String) -> Result<String> {
    let mut result = Vec::default();

    let mut num_zeros = 0;
    hex::decode(bytes.trim_start_matches("0x"))?
        .into_iter()
        .for_each(|byte| {
            if byte == 0 {
                if num_zeros == u8::MAX {
                    fill_zeros(&mut result, &mut num_zeros);
                }
                num_zeros += 1;
            } else {
                fill_zeros(&mut result, &mut num_zeros);
                result.push(byte);
            }
        });
    fill_zeros(&mut result, &mut num_zeros);

    Ok(hex::encode(result))
}

/// ZerkDekompress a byte array
/// Take compressed bytes and return the original bytes with zeros added back in
/// Inefficient, but eh, it's for differential testing. Clean up later.
pub fn zero_dekompress(bytes: String) -> Result<String> {
    let bytes = hex::decode(bytes.trim_start_matches("0x"))?;
    let mut result = Vec::default();

    let mut iter = bytes.into_iter().peekable();
    while let Some(byte) = iter.next() {
        if let Some(&next_byte) = iter.peek() {
            if next_byte == 0 {
                // Fill `byte` number of 0s into the result array
                iter.next();
                result.resize(result.len() + byte as usize, 0);
            } else {
                // Copy `byte` into the result array
                result.push(byte);
            }
        } else {
            // Copy `byte` into the result array
            result.push(byte);
        }
    }
    Ok(hex::encode(result))
}

/// Append RLE zeros to the vector if necessary
fn fill_zeros(v: &mut Vec<u8>, num_zeros: &mut u8) {
    if *num_zeros > 0 {
        v.push(*num_zeros);
        v.push(0);
        *num_zeros = 0;
    }
}

#[cfg(test)]
mod test {
    #[test]
    pub fn test_zero_kompress_middle() {
        let input_value = String::from("7f6b590c000000000000220000ff");
        let output_value = super::zero_kompress(input_value).unwrap();
        let expected_value = String::from("7f6b590c0600220200ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_kompress_edge_end() {
        let input_value = String::from("00000000ff");
        let output_value = super::zero_kompress(input_value).unwrap();
        let expected_value = String::from("0400ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_kompress_edge_start() {
        let input_value = String::from("ff00000000");
        let output_value = super::zero_kompress(input_value).unwrap();
        let expected_value = String::from("ff0400");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_kompress_zero_rollover() {
        let input_value = String::from("00").repeat(260);
        let output_value = super::zero_kompress(input_value).unwrap();
        let expected_value = String::from("ff000500");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_kompress_zero_rollover_multiple() {
        let input_value = String::from("00").repeat(255 * 2 + 5);
        let output_value = super::zero_kompress(input_value).unwrap();
        let expected_value = String::from("ff00ff000500");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_dekompress_middle() {
        let input_value = String::from("7f6b590c0600220200ff");
        let output_value = super::zero_dekompress(input_value).unwrap();
        let expected_value = String::from("7f6b590c000000000000220000ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_dekompress_edge_end() {
        let input_value = String::from("0400ff");
        let output_value = super::zero_dekompress(input_value).unwrap();
        let expected_value = String::from("00000000ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_dekompress_edge_start() {
        let input_value = String::from("ff0400");
        let output_value = super::zero_dekompress(input_value).unwrap();
        let expected_value = String::from("ff00000000");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_dekompress_zero_rollover() {
        let input_value = String::from("ff000500");
        let output_value = super::zero_dekompress(input_value).unwrap();
        let expected_value = String::from("00").repeat(260);
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_dekompress_zero_rollover_multiple() {
        let input_value = String::from("ff00ff000500");
        let output_value = super::zero_dekompress(input_value).unwrap();
        let expected_value = String::from("00").repeat(255 * 2 + 5);
        assert_eq!(output_value, expected_value);
    }
}
