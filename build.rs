use std::env;
use std::fs::File;
use std::io::{BufWriter, BufReader, Write};
use std::path::Path;
use phf_codegen;
use serde::{Deserialize, Serialize};
use std::error::Error;

#[derive(Serialize,Deserialize,Debug)]
struct GemojiEmoji {
    emoji : String,
    description: String,
    category: String,
    aliases: Vec<String>,
    tags: Vec<String>,
    unicode_version: String,
    ios_version: String,
    skin_tones: Option<bool>,
}

fn read_emojis<P: AsRef<Path>>(path: P) -> Result<Vec<GemojiEmoji>, Box<dyn Error>> {
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    let x = serde_json::from_reader(reader)?;
    Ok(x)
}

fn format_gemoji(x: &GemojiEmoji) -> String {
    format!(
        "Emoji{{ emoji: \"{}\", description: \"{}\", tags: &[{}] }}",
        x.emoji, x.description, x.tags.iter().chain(x.aliases.iter().skip(1))
                                      .map(|tag| { format!("\"{}\"", tag) })
                                      .intersperse(", ".to_string())
                                      .collect::<String>()
        )
}

fn main() {
    let path = Path::new(&env::var("OUT_DIR").unwrap()).join("emoji_generated.rs");
    let mut file = BufWriter::new(File::create(&path).unwrap());

    let emojis = read_emojis(Path::new("gemoji/db/emoji.json")).unwrap();

    writeln!(
        &mut file,
        "pub const EMOJI_MAP: phf::Map<&'static str, Emoji> = \n{};",
        emojis.iter().fold(&mut phf_codegen::Map::new(),
                          |gen_map, e| gen_map.entry(e.aliases[0].as_str(), format_gemoji(&e).as_str()))
                     .build()
    ).unwrap();
}
