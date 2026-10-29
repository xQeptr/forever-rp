-- Forever RP v0.9.15: dedicated alcohol regular RP samples (30 /me + 30 /say).
-- Alcohol samples are opt-in: detection never activates an item automatically.
local A=ForeverRP
local previous=A.GetSamplePack
local alcohol={
  me={
    [==[drinks {item} and briefly considers becoming a professional tavern critic.]==],
    [==[raises {item} in a toast to decisions that have not yet gone terribly wrong.]==],
    [==[samples {item}. "A bold flavor. A surprisingly timid aftertaste."]==],
    [==[sips {item} with the solemn focus of a scholar examining ancient runes.]==],
    [==[drinks {item}. "I detect notes of oak, regret, and questionable judgment."]==],
    [==[uncorks {item} and offers the bottle a very respectful nod.]==],
    [==[raises {item} to the party. "To excellent plans and the people who ignore them."]==],
    [==[savors {item} and declares the tavern keeper an artist of uncertain talent.]==],
    [==[finishes {item}. "I believe the room has become more interesting."]==],
    [==[inspects {item}. "A reputable vintage, if one ignores the label."]==],
    [==[holds up {item} and waits for someone to propose a toast worth remembering.]==],
    [==[drinks {item} as though this were a perfectly legitimate battle preparation.]==],
    [==[samples {item} and squints thoughtfully at the empty bottle.]==],
    [==[raises {item}. "To another peaceful evening, however unlikely."]==],
    [==[drinks {item} and insists that the floor has always tilted slightly.]==],
    [==[finishes {item}. "I can still pronounce every word. Most of them, anyway."]==],
    [==[sips {item}. "Ah yes, the unmistakable taste of a tavern discount."]==],
    [==[drinks {item} and attempts to look dignified despite the circumstances.]==],
    [==[offers {item} a brief sniff before making a remarkably brave decision.]==],
    [==[finishes {item} and asks the empty glass whether it has any objections.]==],
    [==[raises {item} toward the nearest adventurer. "May our aim remain better than our judgment."]==],
    [==[samples {item} with the suspicion usually reserved for suspicious quest givers.]==],
    [==[drinks {item}. "A little courage, conveniently bottled."]==],
    [==[grins over {item}. "This tastes like the beginning of a side quest."]==],
    [==[savors {item} and wonders whether the barkeep offers a loyalty program.]==],
    [==[drinks {item} and studies the ceiling with unexpected appreciation.]==],
    [==[raises {item} with the confidence of someone who has not read the warning label.]==],
    [==[drinks {item}. "The healing properties are... emotionally persuasive."]==],
    [==[finishes {item} and declares the situation "entirely under control."]==],
    [==[sips {item} and quietly hopes tomorrow does not require a saving throw.]==],
  },
  say={
    [==[A toast! May {item} improve our odds, if not our decisions.]==],
    [==[I would recommend {item}, though perhaps not before a difficult staircase.]==],
    [==[If anyone asks, {item} is part of my tactical preparations.]==],
    [==[One more {item} and I may finally understand the quest instructions.]==],
    [==[A fine {item}. It has the confidence of something brewed without supervision.]==],
    [==[I am evaluating {item} purely for scholarly purposes.]==],
    [==[Has anyone else noticed that {item} tastes better after a failed pull?]==],
    [==[To the brave, the foolish, and whoever paid for this {item}!]==],
    [==[If the plan fails, we may at least blame the {item}.]==],
    [==[This {item} is either excellent or I have very low standards.]==],
    [==[Never underestimate the morale benefits of a well-timed {item}.]==],
    [==[I trust someone is keeping a record of my opinions on {item}.]==],
    [==[The barkeep swore this {item} was safe. How very reassuring.]==],
    [==[I would like to propose a toast with {item}: to fewer surprises.]==],
    [==[I have no regrets about {item}. Ask me again tomorrow.]==],
    [==[This {item} is better company than half the dungeon.]==],
    [==[Let us drink {item} responsibly. Or at least memorably.]==],
    [==[I am not drunk. I am merely considering {item} from several angles.]==],
    [==[I could quit {item} at any time. Once this bottle is finished.]==],
    [==[If I start singing, kindly confiscate the {item}.]==],
    [==[I am beginning to appreciate the philosophical depth of {item}.]==],
    [==[Who needs a battle cry when we have {item}?]==],
    [==[I have always said {item} is best enjoyed among questionable friends.]==],
    [==[May this {item} grant us confidence without reducing our common sense.]==],
    [==[If we survive, remind me to order another {item}.]==],
    [==[I can still count the bottles of {item}. That is encouraging.]==],
    [==[One should never negotiate with a goblin after too much {item}.]==],
    [==[This {item} has a suspiciously persuasive personality.]==],
    [==[There are better reasons to celebrate, but {item} will do.]==],
    [==[To a glorious adventure and a mercifully short hangover from {item}!]==],
  },
}
function A:GetSamplePack(category,language,channel)
  if category=='alcohol' and language~='de' then
    local list=alcohol[channel=='say' and 'say' or 'me']
    local copy={}
    for i,v in ipairs(list) do copy[i]=v end
    return copy
  end
  return previous(self,category,language,channel)
end
