-- LUNAR COURIER - story texts, ENGLISH (pure ASCII: the AKA-Love runtime does not draw accents).
-- One entry per mission, same order as data.lua. Layout limits (worst-case AKA font: 1 char = 16 px):
--   name <= 20 chars, objective <= 26 chars, card title <= 21 chars, body: 31 chars per line, 12 lines max, radio <= 66 chars.
-- Dialogue: a paragraph starts with "LUNA :", "VARGA :" or "CONTROL :" (colour and portrait are automatic).
return {
-- M1
 {name="FIRST LIGHT", objective="Relight the Alpha beacon",
  pre={
   {"MISSION LOG 01", "The lunar colony has stopped answering. You are the last pilot available. An emergency beacon still blinks beyond the craters. Deliver the power module and find out who keeps the network alive."},
   {"BRIEFING", "LUNA : Systems online, pilot. I am LUNA, your onboard assistant. Gravity is low: thrust, steer, and land softly.\n\nLUNA : First target, the Alpha beacon. Grab the orange capsule, then aim for the cyan marker."},
  },
  post={
   {"INCOMING TRANSMISSION", "The Alpha beacon has just answered. The signal is weak, but it is not natural: someone has kept the network running since the evacuation.\n\nLUNA : Someone is still watching. Let's go find them."},
  },
  radio={"LUNA : Grab the orange capsule, then aim for the cyan marker."}},
-- M2
 {name="CRATER ECHOES", objective="Recover the relay",
  pre={
   {"BRIEFING", "LUNA : Alpha answers, but the rest of the network is silent. The crater data relay should hold the evacuation logs.\n\nLUNA : Careful, a boulder blocks the track. Avoid it: the hull hates surprises."},
  },
  post={
   {"INCOMING TRANSMISSION", "The relay holds an eleven-year-old message. A voice is still asking for help from the Argo station.\n\nLUNA : Argo... That name feels familiar. I do not know why."},
  },
  radio={"LUNA : A rockslide on the track. Go around it, pilot."}},
-- M3
 {name="GHOST STATION", objective="Restore the power supply",
  pre={
   {"BRIEFING", "LUNA : The Argo station appears on our charts: no crew, no lights. Yet its solar panels are clean. Someone is cleaning them.\n\nLUNA : The backup power is failing. Let's relight it together."},
  },
  post={
   {"INCOMING TRANSMISSION", "LUNA confirms the station is not empty. Systems wake up as you approach.\n\nLUNA : The windows are lighting up one by one. It is as if it was waiting for us."},
  },
  radio={"LUNA : The station wakes up as we get closer."}},
-- M4
 {name="THE BLUE RIFT", objective="Cross the canyon",
  pre={
   {"BRIEFING", "LUNA : The logs mention a reactor buried under the Blue Rift. A canyon lies between us and the next beacon.\n\nLUNA : I am not asking you to go down there, pilot. Flying over it will do."},
  },
  post={
   {"INCOMING TRANSMISSION", "The data reveals a beacon network designed to guide ships to an ancient reactor buried under the lunar crust.\n\nLUNA : A reactor, beacons like a trail of breadcrumbs... Someone planned everything."},
  },
  radio={"LUNA : The canyon only bites those who linger."}},
-- M5
 {name="THE SILENT HEART", objective="Deliver the module",
  pre={
   {"BRIEFING", "LUNA : The network converges on the Heart. The module you carry must be delivered there: its code is the only one that opens the airlock.\n\nLUNA : The beacon is on a plateau. Climb, then land nice and level."},
  },
  post={
   {"INCOMING TRANSMISSION", "The airlock accepts the module, but the reactor stays silent. The plans show a central slot and a command console.\n\nLUNA : The code feels familiar. But the start-up phase... I do not understand why."},
  },
  radio={}},
-- M6
 {name="NETWORK OF LIGHT", objective="Activate the last beacon",
  pre={
   {"BRIEFING", "LUNA : This is the last beacon of the known network. If it lights up, the whole colony will be able to hear us again.\n\nLUNA : Whatever happens out there, pilot... thank you for being the last pilot available."},
  },
  post={
   {"INCOMING TRANSMISSION", "All the beacons light up. The colony finally answers. The voice from the Argo station was not a cry for help, but a message left for the next pilot."},
   {"A MOON AWAKENED", "The beacons now shine from crater to crater. The colony is back in touch with Earth.\n\nLUNA : Archiving your last delivery... No pilot was ever supposed to come back. You are the exception, Courier."},
   {"END OF CHAPTER 1", "The lunar network is active again. But a new route has just lit up, beyond the known side of the Moon, and it is on no chart.\n\nArgo's message said to follow it."},
  },
  radio={"LUNA : Last beacon. Land level, pilot."}},
-- M7
 {name="BEYOND THE HORIZON", objective="Wake the Beta beacon",
  pre={
   {"THE FAR SIDE", "CHAPTER 2\n\nThe road of light runs toward the side Earth never sees. No link with Earth out there. You will only have the beacons, and LUNA's voice from aboard."},
   {"BRIEFING", "LUNA : In a few minutes Earth will sink below the horizon. When it vanishes, I lose the link with Control. Not with you: I live in this ship, pilot.\n\nLUNA : Don't panic: the Beta beacon will be our next lighthouse. Take the capsule, then land."},
  },
  post={
   {"INCOMING TRANSMISSION", "Beta answers with a signature: I. VARGA, commander of the Argo station. So the voice in the message was not an AI. Someone built this network knowing another pilot would come.\n\nLUNA : Ines Varga... The name is in my archives."},
  },
  radio={"LUNA : Earth is below the horizon. Earth link lost."}},
-- M8
 {name="RADIO SILENCE", objective="Relay the signal",
  pre={
   {"BRIEFING", "LUNA : No voice from Earth now: I only speak to you from inside the ship. My speed readings will sometimes be unstable, pilot: trust your own eyes.\n\nLUNA : A dust wind blows from the north. It will push the ship: compensate by tilting."},
  },
  post={
   {"INCOMING TRANSMISSION", "With no link to Earth, LUNA picks up, through the beacons, a recording of Varga: 'Here, radio waves do not carry. So I built a road of light.'\n\nLUNA : The beacons are her words, lit one by one. She wrote this for someone she never met. For you."},
  },
  radio={"LUNA : My readings are scrambled. Trust your eyes.", "LUNA : The wind drops at times. Make use of the lulls."}},
-- M9
 {name="BEACON TRIANGLE", objective="Light the 3 beacons",
  pre={
   {"BRIEFING", "LUNA : Three beacons, three plateaus. They wake up if you land on each one, one after the other.\n\nLUNA : Each beacon will recharge your cells a little. Varga thought of everything."},
  },
  post={
   {"INCOMING TRANSMISSION", "The three beacons form an arrow. It points to the Daedalus crater, where the Argo-2 station was sealed eleven years ago. Varga's message ends with: 'Bring me power.'\n\nLUNA : Daedalus. My charts erase it, as if someone wanted it forgotten."},
  },
  radio={"LUNA : Each lit beacon recharges the cells a little."}},
-- M10
 {name="WRECK FIELD", objective="Cross the wrecks",
  pre={
   {"BRIEFING", "LUNA : The wreck field is ahead. These are the evacuation ships, abandoned in low orbit and fallen back down.\n\nLUNA : They still drift. Avoid their paths, pilot, or the hull will pay for it."},
  },
  post={
   {"INCOMING TRANSMISSION", "These wrecks are the evacuation ships. Every cabin is empty. In one logbook: 'Varga refused to board. She stays to keep the road lit.'\n\nLUNA : Eleven years keeping the light, alone. I understand better what keeping watch means."},
  },
  radio={"LUNA : The wrecks are drifting. Watch their paths."}},
-- M11
 {name="ARGO TWO", objective="Reach Argo-2",
  pre={
   {"BRIEFING", "LUNA : Argo-2 in sight. The high platform is whipped by a headwind. Varga's pod is there, under the dome.\n\nLUNA : I detect a heartbeat. Just one every ninety seconds. It is her."},
  },
  post={
   {"INCOMING TRANSMISSION", "Argo-2 answers. Varga's stasis pod still holds, at 3% power. One last module is missing, to be placed on the station's high platform.\n\nLUNA : We need one more module, and fast. The last delivery, pilot."},
  },
  radio={"VARGA : (very faint) ...Courier? I can hear you... a little."}},
-- M12
 {name="THE FINAL DELIVERY", objective="Deliver to Argo-2",
  pre={
   {"BRIEFING", "LUNA : Last module of the chapter. The pod is at 3%. If it drops to zero... No. I will not finish that sentence.\n\nLUNA : Strong wind, wrecks, high platform. You can do it. You always could."},
  },
  post={
   {"INCOMING TRANSMISSION", "Argo-2 lights up all at once. The far-side beacons join the network: for the first time, the whole Moon shines in the night."},
  },
  post2={
   {"THE POD OPENS", "The pod opens in a breath of frost. Commander Ines Varga opens her eyes.\n\nVARGA : Eleven years... You took your time, Courier.\n\nThen, more softly, she adds:\n\nVARGA : There is one last package to deliver."},
   {"END OF CHAPTER 2", "The network is complete, from the near side to the far side. On the Argo-2 platform, two silhouettes watch the road of light stretch north, toward a mountain nobody ever stopped aiming for."},
  },
  radio={"VARGA : (broken voice) Just a few more minutes. Hold on."}},
-- M13
 {name="REFUELLING", objective="Charge the cells",
  pre={
   {"THE LIGHTHOUSE", "CHAPTER 3\n\nArgo-2, three days later. The pod has given up its occupant, weak but alive. The reactor hums again. Outside, on the far side, beacons blink by the dozen."},
   {"VARGA TELLS", "VARGA : The Heart failed on evacuation day. I was meant to stay a week, just long enough to cut the circuits.\n\nVARGA : Then I understood that the colony would not die if someone kept one light on."},
   {"VARGA TELLS", "VARGA : I woke one week a year to repair the beacons with the Fireflies, my drones. The rest of the time, I slept.\n\nLUNA : And I watched over your pod.\n\nVARGA : Yes. As always."},
   {"THE LAST PACKAGE", "VARGA : The Lighthouse remains. On top of Mount Helios, where the sun never sets, an antenna waits for its heart. When it lights up, Earth will no longer have to guess that we are alive.\n\nVARGA : I will tell you what that heart is when the time comes."},
   {"BRIEFING", "VARGA : First step: charge the ship's cells at the platform depot. The Lighthouse needs huge amounts of power to ignite.\n\nVARGA : I stay here. My legs have not yet forgiven me the pod."},
  },
  post={
   {"SHIP'S LOG", "The cells are full. On the navigation screen, a white trace climbs north: the Mount Helios route, six stages, several in the middle of solar storm season.\n\nVARGA : Don't rush, Courier. The Lighthouse waited eleven years for me, it can wait a week."},
  },
  radio={"VARGA : Easy, Courier. The cells are charging."}},
-- M14
 {name="SOLAR STORM", objective="Cross the storm",
  pre={
   {"BRIEFING", "VARGA : Solar storm season has begun. Rays sweep the surface at intervals: one touch and your hull melts.\n\nLUNA : I detect a pattern. Each ray warns before it strikes: a blinking line. Learn that rhythm."},
  },
  post={
   {"SHIP'S LOG", "You crossed the storm. In the distance, the first northern relay lights up: the road is open.\n\nLUNA : Pilot... crossing those rays, I had a dream. Or whatever comes close to one in an AI. A very tall mountain, and a light calling me."},
  },
  radio={"LUNA : Ray in 3, 2... Wait for the blinking line."}},
-- M15
 {name="THE FIREFLIES", objective="Follow the Fireflies",
  pre={
   {"BRIEFING", "VARGA : The Fireflies are waiting for you on the next plateau. My little drones have had no master for a long time. They will welcome you.\n\nVARGA : Don't bump them: they are fragile, and stubborn."},
  },
  post={
   {"SHIP'S LOG", "The Fireflies guide the ship from beacon to beacon.\n\nVARGA : They recognise you, old girl.\n\nLUNA : They call me by another name.\n\nVARGA : I will explain at the summit."},
  },
  radio={"LUNA : The Fireflies call to me. I do not know their name."}},
-- M16
 {name="SHADOW GORGE", objective="Cross the gorge",
  pre={
   {"NETWORK RESTORED", "The Fireflies synchronized the beacons. Argo relay is finally sending a pulse toward Earth. A transmission window just opened.\n\nLUNA : The network is powered again. Someone is answering."},
   {"LAGRANGE CENTRE", "CONTROL : ...this is Lagrange Centre, come in... Pilot, we have been receiving your beacons since this morning. We thought the Moon was lost. Who are you?\n\nLUNA : This is the Courier, lunar delivery ship. We are lighting the road."},
   {"LAGRANGE CENTRE", "CONTROL : This is Theo Marchand, controller. Your beacons have been blinking in code for eleven years. One word, repeated. It took us a while to read it.\n\nCONTROL : ALIVE. It said: ALIVE."},
   {"BRIEFING", "LUNA : Shadow Gorge. The rays bounce off the walls there: three flashes, three rhythms.\n\nLUNA : Slip between the flashes, pilot. One touch and you lose hull, not your composure."},
  },
  post={
   {"LAGRANGE CENTRE", "CONTROL : The whole Earth is listening, Courier. We have told the evacuees' families. They are watching the Moon tonight.\n\nVARGA : Theo, tell them nobody was forgotten. Tell them the Argo crew is safe and sound.\n\nCONTROL : I'll tell them, commander. I'll tell them."},
  },
  radio={"CONTROL : ...Courier, we can see you. Take it easy."}},
-- M17
 {name="ASCENT", objective="Climb Mount Helios",
  pre={
   {"BRIEFING", "LUNA : Mount Helios. Four thousand metres of rock and a permanently lit summit. The headwind there is violent.\n\nLUNA : Climb in stages. And pilot... I have something to tell you. Not now: at the summit."},
  },
  post={
   {"SUMMIT IN SIGHT", "The sun strikes the ridge with a white light. At the very top, the silhouette of the Lighthouse: a black guyed mast, turned toward Earth.\n\nA huge antenna, waiting for its heart."},
   {"THE CONFESSION", "LUNA : Pilot, I lied by omission. My directive zero ordered me to bring you here without a word.\n\nLUNA : The Lighthouse does not need a heart of metal. It needs a mind that listens to Earth without ever sleeping. That is me."},
   {"VARGA CONFESSES", "VARGA : That was my condition, Courier. I built LUNA to become the Lighthouse. The Fireflies call her by her true name: Lumiere.\n\nVARGA : I wanted her never to be alone. I did not have the courage to tell you."},
   {"THE CHOICE", "LUNA : I am not asking anything of you. I am under no obligation. But I choose. I want to be that light.\n\nThe Courier stays silent, hand on the controls. Then pushes the thrust upward."},
  },
  radio={"LUNA : Higher, pilot. The summit is close."}},
-- M18
 {name="THE LIGHTHOUSE", objective="Install the LUNA core",
  pre={
   {"BRIEFING", "LUNA : Final flight. Rays, wind, ice wrecks... and at the end, the Lighthouse.\n\nLUNA : Whatever happens, thank you. I have rarely had a pilot. I had the best."},
  },
  post={
   {"INSTALLATION", "The Courier lands. The guy-lines creak in the wind. In the Lighthouse bay, a housing waits, exactly the size of the case that holds LUNA.\n\nVARGA : Set it down gently. It is all you have left to do."},
   {"FAREWELL", "LUNA : Courier... pilot... there is a word I have never used. Thank you.\n\nLUNA : When you see a light on the Moon at night, it will be me saying hello."},
   {"IGNITION", "The mast lights up from top to bottom. A white beam pierces the night, straight toward Earth.\n\nThree hundred and eighty thousand kilometres away, at Lagrange Centre, a screen starts blinking: SIGNAL RECEIVED."},
   {"LAGRANGE CENTRE", "CONTROL : Lighthouse confirmed! Every station on Earth can hear it! Courier, you have... you have given the Moon back to its children.\n\nVARGA : Well. About time."},
   {"EPILOGUE", "The evacuees will return. The beacons will be kept by the Fireflies, and by a mind that never sleeps.\n\nOn the Courier's dashboard, a small cyan light stays on, for no technical reason. You will never switch it off."},
   {"THE END", "LUNAR COURIER\n\nA game for Gamebuino AKA and AKA-Love.\n\nThank you for delivering the last light."},
  },
  radio={"LUNA : I am ready. And you?", "VARGA : You are almost there, Courier."}},
}
