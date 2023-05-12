use anyhow::Result;
use ethers::utils::hex;

/// ZeroKompress a byte array
/// Inefficient, but eh, it's for differential testing.
pub fn zero_kompress(bytes: String) -> Result<String> {
    let mut result = Vec::default();

    let mut num_zeros = 0;
    hex::decode(bytes)?.into_iter().for_each(|byte| {
        if num_zeros == u8::MAX {
            fill_zeros(&mut result, &mut num_zeros)
        } else if byte == 0 {
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
pub fn zero_dekompress(_bytes: String) -> Result<String> {
    let bytes = hex::decode(_bytes)?;
    let mut result = Vec::default();

    let mut iter = bytes.into_iter().peekable();

    while let Some(byte) = iter.next() {
        if let Some(&next_byte) = iter.peek() {
            if next_byte == 0 {
                // Fill `byte` number of 0s into the result array
                iter.next();
                for _ in 0..byte {
                    result.push(0);
                }  
            } else {
                // Copy `byte` into the result array
                result.push(byte);
            }
        }
    }
    Ok(hex::encode(result))
}

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
    pub fn test_zero_dekompress() {
        let input_value = String::from("7f6b590c0600220200");
        let output_value = super::zero_dekompress(input_value.clone()).unwrap();
        let expected_value = String::from("7f6b590c000000000000220000");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_zero_kompress() {
        let input_value = String::from("7f6b590c000000000000220000");
        let output_value = super::zero_kompress(input_value.clone()).unwrap();
        let expected_value = String::from("7f6b590c0600220200");
        assert_eq!(output_value, expected_value);
    }
}
