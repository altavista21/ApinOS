use std::fs;
use std::process::Command;

fn read_os_release() -> Option<String> {
    let content = fs::read_to_string("/etc/os-release").ok()?;
    content
        .lines()
        .find(|line| line.starts_with("PRETTY_NAME="))
        .map(|line| line.trim_start_matches("PRETTY_NAME=").trim_matches('"').to_owned())
}

fn command_output(program: &str, args: &[&str]) -> Option<String> {
    let output = Command::new(program).args(args).output().ok()?;
    if !output.status.success() {
        return None;
    }
    let value = String::from_utf8_lossy(&output.stdout).trim().to_owned();
    (!value.is_empty()).then_some(value)
}

fn main() {
    println!("ApinOS System Information");
    println!("-------------------------");
    println!("OS: {}", read_os_release().unwrap_or_else(|| "Unknown".into()));
    println!("Kernel: {}", command_output("uname", &["-r"]).unwrap_or_else(|| "Unknown".into()));
    println!("Architecture: {}", command_output("uname", &["-m"]).unwrap_or_else(|| "Unknown".into()));
    println!("Hostname: {}", command_output("hostname", &[]).unwrap_or_else(|| "Unknown".into()));
}
