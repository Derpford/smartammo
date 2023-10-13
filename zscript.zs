version "4.10"

class AmmoWatcher : Inventory {
    // Sits in your inventory and HandlePickup's ammo items.
    // Whenever it finds an ammo item, it grabs that item's ammo type, then checks the amount of that ammo type that's present in the player's inventory.
    // If it finds that ammo type, it checks against its owner's capacity for that ammotype.
    // If the ammo pickup would take the player over capacity...
    // ...it calculates the amount that would be left over...
    // ...then sets the item's amount to the leftover amount...
    // ...then prints a message to the console to tell the player that they got a partial amount of the ammo type...
    // ...then returns true.

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
    }

    override bool HandlePickup(Inventory it) {
        if (it is "Ammo") {
            let pickup = Ammo(it);
            let type = pickup.GetParentAmmo();
            int carry = owner.CountInv(type);
            int max = owner.GetAmmoCapacity(type);
            int diff = (carry + pickup.amount) - max;
            int grabbed = pickup.amount - diff;
            if (diff > 0 && grabbed != 0) {
                // We can't carry all of it.
                owner.GiveInventory(type,grabbed);
                console.printf("Partial pickup (%d of %s)",grabbed,it.GetTag());
                it.amount = diff;
                it.bPICKUPGOOD = false;
                return true;
            }
        }
        return false;
    }
}

class AmmoHandler : EventHandler {
    // Gives players their AmmoWatcher on entry.
    override void PlayerEntered(PlayerEvent e) {
        PlayerInfo player = players[e.PlayerNumber];
        Actor pmob = player.mo;
        pmob.GiveInventory("AmmoWatcher",1);
    }
}