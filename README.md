# Install

cd /etc/nixos  

git clone git@<span></span>github.com:Oxy8/nixos-config.git .  

(Gotta use sudo or chown)  

*(dont forget the . at the end)*  

* SSH ed25519 key needs to be generated manually.  

* Password needs to be set manually using passwd.  

---

# Rebuild

sudo nixos-rebuild boot --flake .#  

---

# Update

nix flake update  

---

# Delete old generations

sudo nix-env --delete-generations 60d --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
nix-store --gc

