resource "aws_key_pair" "msk_key" {
  key_name   = "msk-key"
  public_key = file("~/.ssh/msk-key.pub")
}
