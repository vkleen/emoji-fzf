#[derive(Debug)]
pub struct Emoji<'a> {
    pub emoji : &'a str,
    pub description : &'a str,
    pub tags : &'a [&'a str],
}

include!(concat!(env!("OUT_DIR"), "/emoji_generated.rs"));
