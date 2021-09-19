mod args;
mod emojis;

enum Command {
    Get(String),
    Preview,
}

fn main() {
    let command = args::parse();

    match command {
        Command::Get(name) => display_emoji(&name),
        Command::Preview => preview_emojis(),
    }
}

fn display_emoji(name: &str) {
    if let Some(emoji) = emojis::EMOJI_MAP.get(name) {
        print!("{}", emoji.emoji);
        std::process::exit(0);
    }
    std::process::exit(1);
}

fn preview_emojis() {
    for (key, emoji) in emojis::EMOJI_MAP.entries() {
        println!("{}\t{} {}", key, emoji.description,
                 emoji.tags.join(" ")
                );
    }
}
