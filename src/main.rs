fn main() -> Result<(), Box<dyn std::error::Error>> {
    pollster::block_on(conways_game_of_life::run());
    Ok(())
}
