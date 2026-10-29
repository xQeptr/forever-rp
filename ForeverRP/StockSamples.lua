-- Forever RP v0.9.12 - 20 English last-item RP samples per consumable category.
local A=ForeverRP
local base={
  me={
    [==[searches the satchel for another {item}, but finds only an empty space.]==],
    [==[realizes that was the last {item}. "A most inconvenient discovery."]==],
    [==[checks every pocket for another {item}. None remains.]==],
    [==[stares at the empty place where the {item} used to be.]==],
    [==[takes stock of the supplies. Not a single {item} remains.]==],
    [==[shakes an empty pouch once held full of {item}. "How unfortunate."]==],
    [==[finishes the final {item} and makes a mental note to restock.]==],
    [==[looks for another {item}, then sighs at the barren inventory.]==],
    [==[discovers the supply of {item} has run dry at a most awkward moment.]==],
    [==[checks the bag again, as if another {item} might magically appear.]==],
    [==[considers the empty {item} supply with growing concern.]==],
    [==[makes a polite but pointed note: no more {item} left.]==],
    [==[gently closes an empty pouch after using the last {item}.]==],
    [==[regards the spent {item} with the expression of a disappointed quartermaster.]==],
    [==[discovers that the final {item} has been used. "That could be problematic."]==],
  },
  say={
    [==[That was my last {item}. I shall require a resupply.]==],
    [==[I appear to be out of {item}. How deeply inconvenient.]==],
    [==[The supply of {item} has run dry.]==],
    [==[No more {item} in the bag. Do plan accordingly.]==],
    [==[I regret to announce that the last {item} is gone.]==],
    [==[Another {item} would be most welcome. I have none left.]==],
    [==[I would not count on a second {item}. There is none.]==],
    [==[That concludes our supply of {item}.]==],
    [==[It seems I neglected to pack enough {item}.]==],
    [==[For the record: zero {item} remaining.]==],
    [==[I trust someone planned for a shortage of {item}.]==],
    [==[We should replenish the {item} before the next disaster.]==],
    [==[That was the final {item}. Consider yourselves warned.]==],
    [==[I have consumed my last {item}. Make the next pull count.]==],
    [==[The last {item} is spent. A tactical adjustment may be wise.]==],
  },
}
local variants={
  healthstone={
    me={
      [==[finishes the last {item} and gives the warlock a very deliberate look.]==],
      [==[finds no second {item}, then clears his throat toward the warlock.]==],
      [==[searches for another {item}. "Surely our warlock has a spare."]==],
      [==[consumes the final {item} and waits with impressive patience for service.]==],
      [==[regards the absent {item} with the quiet disappointment of a neglected patron.]==],
    },
    say={
      [==[Warlock, the last {item} has been consumed. Your artistry is requested.]==],
      [==[We appear to be entirely out of {item}. I trust this can be remedied.]==],
      [==[An additional {item} would be appreciated, dear warlock.]==],
      [==[The complimentary {item} service seems to have ended.]==],
      [==[I have no {item} left. Does the kitchen still take orders?]==],
    },
  },
  potion={
    me={
      [==[holds up the empty vial of the last {item}. "A poor time for an empty bottle."]==],
      [==[finds the last {item} gone and pockets the empty glass.]==],
      [==[checks the potion belt for another {item}. Nothing but dust.]==],
      [==[puts away the last vial of {item} and hopes the healer is watching.]==],
      [==[discovers the {item} supply is exhausted just as the battle heats up.]==],
    },
    say={
      [==[That was my final {item}; next time we rely on the healer.]==],
      [==[No more {item}. I hope the alchemist is still open.]==],
      [==[The potion belt is empty of {item}.]==],
      [==[I just drank the last {item}. We might want to be cautious.]==],
      [==[Our remaining {item} count is precisely zero.]==],
    },
  },
  drink={
    me={
      [==[finishes the very last {item} and looks toward the nearest tavern.]==],
      [==[peers into an empty cup. The {item} supply is gone.]==],
      [==[sets down the last {item} with a faint sigh.]==],
      [==[checks the waterskin. Not a drop of {item} remains.]==],
      [==[holds up an empty cup once filled with {item}.]==],
    },
    say={
      [==[I seem to be out of {item}. That is poor hospitality.]==],
      [==[The last {item} is gone. A tavern would be welcome.]==],
      [==[We have run out of {item}. I shall have words with the innkeeper.]==],
      [==[I could do with another {item}, if anyone is offering.]==],
      [==[Not a single {item} left. Who planned the refreshments?]==],
    },
  },
  food={
    me={
      [==[finishes the last {item} and brushes the remaining crumbs away.]==],
      [==[looks at the empty ration pouch where {item} once rested.]==],
      [==[realizes there is no more {item} for the road.]==],
      [==[checks for a final serving of {item}, but the plate is empty.]==],
      [==[treats the end of the {item} supply as a personal tragedy.]==],
    },
    say={
      [==[That was the last {item}. Back to hunting for dinner.]==],
      [==[I am out of {item}. Any cooks among us?]==],
      [==[No more {item} in the pack, I am afraid.]==],
      [==[Next stop, a place that serves {item}.]==],
      [==[We should restock on {item} before the next journey.]==],
    },
  },
  bufffood={
    me={
      [==[finishes the last {item} and surveys the empty provision bag.]==],
      [==[counts the remaining {item} rations. Zero.]==],
      [==[looks for another {item} before the next encounter, to no avail.]==],
      [==[consumes the final {item} and nods to the party with concern.]==],
      [==[closes the food pack. The last {item} is gone.]==],
    },
    say={
      [==[That was the final {item}. No more food buffs from this pack.]==],
      [==[I am completely out of {item}. We should prepare more.]==],
      [==[The last {item} has been served. Make it count.]==],
      [==[No more {item}. Perhaps the cook could assist.]==],
      [==[Our {item} rations need replenishing.]==],
    },
  },
  elixir={
    me={
      [==[empties the last {item} and inspects the suddenly bare alchemy kit.]==],
      [==[discovers the final {item} was indeed the final vial.]==],
      [==[checks for another {item}, but the laboratory supply is exhausted.]==],
      [==[puts the last {item} bottle aside with a grim nod.]==],
      [==[realizes the {item} supply is depleted. "Splendid timing."]==],
    },
    say={
      [==[I have used the last {item}. An alchemist would be helpful.]==],
      [==[The {item} supply is empty. A regrettable oversight.]==],
      [==[No more {item}. We must make do.]==],
      [==[Please remind me to restock {item} before the next expedition.]==],
      [==[That was the final {item} vial.]==],
    },
  },
  bandage={
    me={
      [==[folds away the last {item} and realizes the bandage pouch is empty.]==],
      [==[discovers that no more {item} remains to bind the wounds.]==],
      [==[checks the medical kit for another {item} and finds none.]==],
      [==[uses the final {item} and glances toward the healer.]==],
      [==[looks in vain for one last {item}.]==],
    },
    say={
      [==[That was my last {item}. The healer may have to improvise.]==],
      [==[No more {item} in the medical kit.]==],
      [==[I am out of {item}. Keep the wounds to a minimum.]==],
      [==[The last {item} is gone. A new supply is advisable.]==],
      [==[I shall require more {item} soon.]==],
    },
  },
  alcohol={
    me={
      [==[finishes the last {item} and searches unsuccessfully for another round.]==],
      [==[regards the empty {item} supply with theatrical sorrow.]==],
      [==[discovers there is no second {item}. "An outrage."]==],
      [==[checks the flask for another {item}, but finds only air.]==],
      [==[raises an empty bottle where the last {item} used to be.]==],
    },
    say={
      [==[No more {item}. This tavern has failed us.]==],
      [==[I demand another {item}. Regrettably, I have none.]==],
      [==[That was my last {item}. Who is buying the next round?]==],
      [==[We have run dry of {item}. A tragedy!]==],
      [==[Perhaps it is for the best that the {item} is gone.]==],
    },
  },
  other={
    me={
      [==[finds the satchel empty after using the last {item}.]==],
      [==[checks for a spare {item}, but has none left.]==],
      [==[considers the disappearance of the final {item} with mild concern.]==],
      [==[closes the bag after using the last {item}.]==],
      [==[discovers no more {item} remains.]==],
    },
    say={
      [==[The last {item} has been used. I would like another.]==],
      [==[No more {item}. I shall adjust my plans.]==],
      [==[My supply of {item} has been exhausted.]==],
      [==[I have no {item} left. For future reference.]==],
      [==[That was our last {item}.]==],
    },
  },
}
function A:GetStockSamplePack(category,channel)
  local mode=channel=='say' and 'say' or 'me'
  local special=variants[category] or variants.other
  local result={}
  for _,s in ipairs(special[mode]) do result[#result+1]=s end
  for _,s in ipairs(base[mode]) do result[#result+1]=s end
  return result
end
