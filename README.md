# Pre Install

Generate SSH ed25519 key (ssh-keygen -t ed25519 -C "34687508+Oxy8@users.noreply.github.com")

Add new key to github

# Install

cd /etc/nixos

sudo chown -R estevan .

git clone git@github.com:Oxy8/nixos-config.git .  

*(dont forget the . at the end)*  

* Password needs to be set manually  

---

# Rebuild

sudo nixos-rebuild boot --flake .#_hostname_  --impure

---

# Update

nix flake update  

---

# Delete old generations

sudo nix-env --delete-generations 60d --profile /nix/var/nix/profiles/system \
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch \
nix-store --gc

