#![deny(rust_2018_idioms)]

#[cfg(test)]
mod tests {
    use std::{fs, io};
    use std::path::PathBuf;

    #[test]
    fn test_foo() -> io::Result<()> {
        let root = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap())
            .join("../../..");

        let mut entries = fs::read_dir(root.clone())?
            .map(|res| res.map(|e| e.path()))
            .collect::<Result<Vec<_>, io::Error>>()?;

        entries.sort();
        println!("{:#?}", entries);

        let file_path = root.join("fixture.txt");

        let contents = fs::read_to_string(file_path)
            .expect("Should have been able to read the file");

        assert_eq!(contents, "fixture\n");

        Ok(())
    }
}
