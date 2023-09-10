# Install

cd /etc/nixos  

sudo clone git@<span></span>github.com:Oxy8/nixos-config.git .  

*(dont forget the . at the end)*  

* SSH ed25519 key needs to be generated manually.  

* Password needs to be set manually using passwd.  

---

# Rebuild

sudo nixos-rebuild boot --flake .#  

---

# Update

nix flake update  
