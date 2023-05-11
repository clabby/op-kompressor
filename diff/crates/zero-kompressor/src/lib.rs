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
pub fn zero_dekompress(_bytes: String) -> Result<String> {
    // let bytes = hex::decode(bytes)?;
    // let mut result = Vec::default();
    //
    // Ok(hex::encode(result))
    todo!()
}

fn fill_zeros(v: &mut Vec<u8>, num_zeros: &mut u8) {
    if *num_zeros > 0 {
        v.push(*num_zeros);
        v.push(0);
        *num_zeros = 0;
    }
}
