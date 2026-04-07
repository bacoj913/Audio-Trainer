// Models/RFData.swift — RF Planner data: venues, wireless systems, antennas, distros, accessories

import Foundation

// MARK: - RF Environment
enum RFEnvironment: String, CaseIterable {
    case low      = "Low"
    case moderate = "Moderate"
    case busy     = "Busy"
    case veryBusy = "Very Busy"
}

// MARK: - RF Venue
struct RFVenue {
    let name: String
    let type: String
    let capacity: Int
    let city: String
    let region: String   // "US", "EU", "AU", "CA"
    let rfEnv: RFEnvironment
    let notes: String
}

// MARK: - Wireless System
struct FreqBand {
    let band: String
    let range: String
}

struct RFTxItem {
    let name: String
    let cat: String
}

struct RFRxModel {
    let name: String
    let channels: Int
    let cat: String
}

struct RFWirelessSystem {
    let key: String
    let brand: String
    let system: String
    let freqBands: [String: [FreqBand]]
    let receivers: [RFRxModel]
    let handhelds: [RFTxItem]
    let bodypacks: [RFTxItem]
    let iemTx: [RFTxItem]?
    let iemRx: [RFTxItem]?
    let coord: String
}

struct RFListItem {
    let name: String
    let cat: String
}

// MARK: - Venues
// MARK: - Venues
let rfVenues: [RFVenue] = [
    RFVenue(name: "The Blue Note Lounge",        type: "Jazz Club",              capacity: 120,    city: "Chicago, IL",              region: "US", rfEnv: .moderate,  notes: "Low ceiling, brick walls, good RF behavior. Neighboring bars may cause minor interference on busy nights."),
    RFVenue(name: "Riverside Brewing Co.",       type: "Brewery / Bar",          capacity: 250,    city: "Portland, OR",             region: "US", rfEnv: .moderate,  notes: "Industrial HVAC introduces some RF noise floor. Open floor plan is otherwise friendly for wireless."),
    RFVenue(name: "Sunset Rooftop Bar",          type: "Rooftop Venue",          capacity: 180,    city: "Miami, FL",                region: "US", rfEnv: .low,       notes: "Open sky great for RF line-of-sight. Neighboring high-rises may create unexpected multipath."),
    RFVenue(name: "The Palace Theatre",          type: "Historic Theater",       capacity: 850,    city: "Columbus, OH",             region: "US", rfEnv: .low,       notes: "Plaster walls and ornate interior can cause multipath reflections. Generally clean RF environment."),
    RFVenue(name: "Orpheum Performing Arts Ctr", type: "Performing Arts Center", capacity: 2400,   city: "Memphis, TN",              region: "US", rfEnv: .moderate,  notes: "Large stage requires distributed antenna coverage. Multiple HVAC zones across building."),
    RFVenue(name: "Lakeside Community Church",   type: "House of Worship",       capacity: 1800,   city: "Nashville, TN",            region: "US", rfEnv: .low,       notes: "Campus already uses 700/800 MHz comms. Newer LED stage lighting may cause narrowband interference."),
    RFVenue(name: "Grand Hyatt Ballroom",        type: "Hotel Ballroom",         capacity: 600,    city: "New York, NY",             region: "US", rfEnv: .busy,      notes: "Dense hotel Wi-Fi infrastructure. Multiple simultaneous events on property likely. Coordinate with AV department."),
    RFVenue(name: "Convention Center Hall A",    type: "Convention Center",      capacity: 5000,   city: "Las Vegas, NV",            region: "US", rfEnv: .veryBusy,  notes: "Dozens of simultaneous productions. Exhibitor Wi-Fi extremely dense. Extensive coordination with show organizer essential."),
    RFVenue(name: "Red Rocks Amphitheatre",      type: "Outdoor Amphitheater",   capacity: 9500,   city: "Morrison, CO",             region: "US", rfEnv: .moderate,  notes: "Open air with rocky terrain and altitude. Broadcast trucks often on-site. Clear line-of-sight generally available."),
    RFVenue(name: "Coachella Main Stage",        type: "Outdoor Festival Stage", capacity: 100000, city: "Indio, CA",                region: "US", rfEnv: .veryBusy,  notes: "Festival environment with dozens of simultaneous active systems. Coordination with adjacent stages and broadcast critical."),
    RFVenue(name: "Metro Arena",                 type: "Indoor Arena",           capacity: 18000,  city: "Atlanta, GA",              region: "US", rfEnv: .veryBusy,  notes: "Dense LED video wall broadband noise. Scoreboard systems active on event days. Tour advance coordination required."),
    RFVenue(name: "Madison Square Garden",       type: "Arena / Stadium",        capacity: 20789,  city: "New York, NY",             region: "US", rfEnv: .veryBusy,  notes: "Dense urban RF environment on all sides. Legacy building infrastructure. Must coordinate with house systems team."),
    RFVenue(name: "O2 Arena",                    type: "Indoor Arena",           capacity: 20000,  city: "London, UK",               region: "EU", rfEnv: .veryBusy,  notes: "Post-700 MHz clearance: avoid 694 MHz+. Dense urban environment. Coordination with broadcast and house systems required."),
    RFVenue(name: "Royal Albert Hall",           type: "Concert Hall",           capacity: 5272,   city: "London, UK",               region: "EU", rfEnv: .moderate,  notes: "Large historic hall with heavy visitor density and strong Wi-Fi presence. Reflections are manageable with careful antenna placement."),
    RFVenue(name: "Olympiahalle München",        type: "Arena",                  capacity: 15500,  city: "Munich, Germany",          region: "EU", rfEnv: .busy,      notes: "Large event-day comms presence and complex steel structure. Careful coordination required."),
    RFVenue(name: "Sydney Opera House",          type: "Concert Hall",           capacity: 2679,   city: "Sydney, Australia",        region: "AU", rfEnv: .moderate,  notes: "Iconic shell architecture creates interesting reflection behavior. Coordinate with house RF engineer."),
    RFVenue(name: "Rogers Centre",               type: "Domed Stadium",          capacity: 53500,  city: "Toronto, Canada",          region: "CA", rfEnv: .veryBusy,  notes: "Steel dome creates significant RF multipath. Distributed antenna system recommended for large shows."),

    // MARK: - Major US arenas 
    RFVenue(name: "United Center",               type: "Arena",                  capacity: 20900,  city: "Chicago, IL",              region: "US", rfEnv: .veryBusy,  notes: "Large scoreboard and dense in-bowl production systems. Strong house RF presence on event days."),
    RFVenue(name: "Crypto.com Arena",            type: "Arena",                  capacity: 19000,  city: "Los Angeles, CA",          region: "US", rfEnv: .veryBusy,  notes: "Downtown RF congestion, broadcast presence, and heavy wireless density make coordination critical."),
    RFVenue(name: "Kia Forum",                   type: "Arena",                  capacity: 17500,  city: "Inglewood, CA",            region: "US", rfEnv: .veryBusy,  notes: "Major touring room with dense wireless use and nearby stadium/event infrastructure."),
    RFVenue(name: "Intuit Dome",                 type: "Arena",                  capacity: 18000,  city: "Inglewood, CA",            region: "US", rfEnv: .veryBusy,  notes: "New venue with heavy digital infrastructure, dense Wi-Fi, and strong production footprint."),
    RFVenue(name: "Honda Center",                type: "Arena",                  capacity: 18000,  city: "Anaheim, CA",              region: "US", rfEnv: .busy,      notes: "Large bowl with typical arena scoreboard and concourse Wi-Fi environment."),
    RFVenue(name: "SAP Center",                  type: "Arena",                  capacity: 17500,  city: "San Jose, CA",             region: "US", rfEnv: .busy,      notes: "Urban tech-heavy RF environment with strong Wi-Fi and in-house systems."),
    RFVenue(name: "Chase Center",                type: "Arena",                  capacity: 18000,  city: "San Francisco, CA",        region: "US", rfEnv: .veryBusy,  notes: "Dense corporate and fan device presence. Strong coordination needed for major shows."),
    RFVenue(name: "Golden 1 Center",             type: "Arena",                  capacity: 17500,  city: "Sacramento, CA",           region: "US", rfEnv: .busy,      notes: "Modern bowl with robust Wi-Fi and typical arena interference sources."),
    RFVenue(name: "Ball Arena",                  type: "Arena",                  capacity: 18000,  city: "Denver, CO",               region: "US", rfEnv: .busy,      notes: "Large urban arena with broadcast and house systems. Altitude itself is not an RF issue, but logistics can be."),
    RFVenue(name: "Fiddler's Green Amphitheatre",type: "Outdoor Amphitheater",   capacity: 18000,  city: "Greenwood Village, CO",    region: "US", rfEnv: .moderate,  notes: "Open-air amphitheater with good line-of-sight, but surrounding development can add noise floor."),
    RFVenue(name: "XL Center",                   type: "Arena",                  capacity: 16000,  city: "Hartford, CT",             region: "US", rfEnv: .busy,      notes: "Indoor bowl with moderate-to-heavy event-day RF coordination needs."),
    RFVenue(name: "CFG Bank Arena",              type: "Arena",                  capacity: 14000,  city: "Baltimore, MD",            region: "US", rfEnv: .busy,      notes: "Urban venue with moderate downtown congestion and strong guest-device density."),
    RFVenue(name: "TD Garden",                   type: "Arena",                  capacity: 19500,  city: "Boston, MA",               region: "US", rfEnv: .veryBusy,  notes: "Dense city-center RF environment with strong broadcast and house-system activity."),
    RFVenue(name: "Agganis Arena",               type: "Arena",                  capacity: 7200,   city: "Boston, MA",               region: "US", rfEnv: .moderate,  notes: "University arena with moderate local RF load and less broadcast complexity than pro rooms."),
    RFVenue(name: "Little Caesars Arena",        type: "Arena",                  capacity: 19500,  city: "Detroit, MI",              region: "US", rfEnv: .veryBusy,  notes: "Large multi-use venue with heavy in-house systems and urban spectrum congestion."),
    RFVenue(name: "Target Center",               type: "Arena",                  capacity: 19000,  city: "Minneapolis, MN",          region: "US", rfEnv: .busy,      notes: "Modernized bowl with strong Wi-Fi and event-day production density."),
    RFVenue(name: "Xcel Energy Center",          type: "Arena",                  capacity: 18000,  city: "St. Paul, MN",             region: "US", rfEnv: .busy,      notes: "Indoor arena with typical NHL/NBA-scale wireless density and coordination needs."),
    RFVenue(name: "Enterprise Center",           type: "Arena",                  capacity: 18000,  city: "St. Louis, MO",            region: "US", rfEnv: .busy,      notes: "Large scoreboard systems and downtown RF density require standard arena coordination."),
    RFVenue(name: "T-Mobile Arena",              type: "Arena",                  capacity: 20000,  city: "Las Vegas, NV",            region: "US", rfEnv: .veryBusy,  notes: "Las Vegas hotel/casino RF environment plus major event infrastructure make this a very dense coordination site."),
    RFVenue(name: "Prudential Center",           type: "Arena",                  capacity: 17500,  city: "Newark, NJ",               region: "US", rfEnv: .veryBusy,  notes: "Dense northeast corridor RF environment with heavy event-day load."),
    RFVenue(name: "UBS Arena",                   type: "Arena",                  capacity: 17500,  city: "Elmont, NY",               region: "US", rfEnv: .veryBusy,  notes: "New-build arena with extensive guest Wi-Fi and strong house production systems."),
    RFVenue(name: "KeyBank Center",              type: "Arena",                  capacity: 19000,  city: "Buffalo, NY",              region: "US", rfEnv: .busy,      notes: "Moderate-to-heavy in-bowl RF with sports and concert infrastructure."),
    RFVenue(name: "Spectrum Center",             type: "Arena",                  capacity: 19000,  city: "Charlotte, NC",            region: "US", rfEnv: .busy,      notes: "Urban arena with robust fan Wi-Fi, LED, and production systems."),
    RFVenue(name: "PNC Arena",                   type: "Arena",                  capacity: 19000,  city: "Raleigh, NC",              region: "US", rfEnv: .busy,      notes: "Large indoor venue with standard sports/concert wireless density."),
    RFVenue(name: "Rocket Arena",                type: "Arena",                  capacity: 19500,  city: "Cleveland, OH",            region: "US", rfEnv: .busy,      notes: "Major downtown arena with strong in-house systems and typical urban RF congestion."),
    RFVenue(name: "Nationwide Arena",            type: "Arena",                  capacity: 18000,  city: "Columbus, OH",             region: "US", rfEnv: .busy,      notes: "Typical modern arena wireless load with sports, show, and guest-device traffic."),
    RFVenue(name: "Paycom Center",               type: "Arena",                  capacity: 18000,  city: "Oklahoma City, OK",        region: "US", rfEnv: .busy,      notes: "Large arena with moderate downtown congestion and strong in-house infrastructure."),
    RFVenue(name: "Wells Fargo Center",          type: "Arena",                  capacity: 20000,  city: "Philadelphia, PA",         region: "US", rfEnv: .veryBusy,  notes: "Major market arena with high wireless density, LED, broadcast, and sports system overlap."),
    RFVenue(name: "PPG Paints Arena",            type: "Arena",                  capacity: 19000,  city: "Pittsburgh, PA",           region: "US", rfEnv: .busy,      notes: "Large arena bowl with event-day production RF and typical guest-device density."),
    RFVenue(name: "Bridgestone Arena",           type: "Arena",                  capacity: 19000,  city: "Nashville, TN",            region: "US", rfEnv: .veryBusy,  notes: "Broadway district density plus touring and sports infrastructure create a busy RF environment."),
    RFVenue(name: "FedExForum",                  type: "Arena",                  capacity: 18000,  city: "Memphis, TN",              region: "US", rfEnv: .busy,      notes: "Large downtown bowl with standard multi-use arena coordination needs."),
    RFVenue(name: "American Airlines Center",    type: "Arena",                  capacity: 20000,  city: "Dallas, TX",               region: "US", rfEnv: .veryBusy,  notes: "Major-market arena with dense RF coordination requirements."),
    RFVenue(name: "Toyota Center",               type: "Arena",                  capacity: 19000,  city: "Houston, TX",              region: "US", rfEnv: .veryBusy,  notes: "Urban venue with strong broadcast, sports, LED, and fan-device density."),
    RFVenue(name: "Moody Center",                type: "Arena",                  capacity: 15000,  city: "Austin, TX",               region: "US", rfEnv: .busy,      notes: "Modern venue with robust digital infrastructure and strong show-day wireless use."),
    RFVenue(name: "Frost Bank Center",           type: "Arena",                  capacity: 18500,  city: "San Antonio, TX",          region: "US", rfEnv: .busy,      notes: "Indoor arena with moderate market congestion and typical arena systems."),
    RFVenue(name: "Delta Center",                type: "Arena",                  capacity: 18500,  city: "Salt Lake City, UT",       region: "US", rfEnv: .busy,      notes: "Dense in-bowl wireless environment with arena guest Wi-Fi and show infrastructure."),
    RFVenue(name: "Climate Pledge Arena",        type: "Arena",                  capacity: 17500,  city: "Seattle, WA",              region: "US", rfEnv: .veryBusy,  notes: "Heavy wireless infrastructure, dense fan devices, and modern production ecosystem."),
    RFVenue(name: "Fiserv Forum",                type: "Arena",                  capacity: 17500,  city: "Milwaukee, WI",            region: "US", rfEnv: .busy,      notes: "Modern multi-use arena with robust digital systems and typical bowl RF density."),

    // MARK: - Major Canadian arenas 
    RFVenue(name: "Scotiabank Arena",            type: "Arena",                  capacity: 19000,  city: "Toronto, Canada",          region: "CA", rfEnv: .veryBusy,  notes: "Major downtown arena with dense guest-device presence and heavy broadcast/show-day systems."),
    RFVenue(name: "Coca-Cola Coliseum",          type: "Arena",                  capacity: 8000,   city: "Toronto, Canada",          region: "CA", rfEnv: .moderate,  notes: "Smaller arena but in a dense urban venue district with moderate surrounding RF activity."),
    RFVenue(name: "Place Bell",                  type: "Arena",                  capacity: 10000,  city: "Laval, Canada",            region: "CA", rfEnv: .moderate,  notes: "Regional arena with manageable RF profile and moderate in-house density."),
    RFVenue(name: "Bell Centre",                 type: "Arena",                  capacity: 21000,  city: "Montreal, Canada",         region: "CA", rfEnv: .veryBusy,  notes: "Large downtown arena with dense city RF and heavy event-day infrastructure."),
    RFVenue(name: "Place des Arts",              type: "Performing Arts Center", capacity: 3000,   city: "Montreal, Canada",         region: "CA", rfEnv: .moderate,  notes: "Multi-hall complex with dense in-building systems and manageable urban spectrum."),
    RFVenue(name: "Centre Vidéotron",            type: "Arena",                  capacity: 18000,  city: "Quebec City, Canada",      region: "CA", rfEnv: .busy,      notes: "Large modern venue with strong internal wireless systems and guest-device load."),
    RFVenue(name: "Canadian Tire Centre",        type: "Arena",                  capacity: 19000,  city: "Ottawa, Canada",           region: "CA", rfEnv: .busy,      notes: "Large suburban arena with strong in-house systems but slightly less urban spillover than downtown venues."),
    RFVenue(name: "Canada Life Centre",          type: "Arena",                  capacity: 15500,  city: "Winnipeg, Canada",         region: "CA", rfEnv: .busy,      notes: "Mid-size major arena with standard sports/show RF density."),
    RFVenue(name: "SaskTel Centre",              type: "Arena",                  capacity: 15000,  city: "Saskatoon, Canada",        region: "CA", rfEnv: .moderate,  notes: "Regional major room with moderate spectrum pressure and manageable coordination."),
    RFVenue(name: "Scotiabank Saddledome",       type: "Arena",                  capacity: 19000,  city: "Calgary, Canada",          region: "CA", rfEnv: .busy,      notes: "Distinct building geometry can create RF reflections. Standard pro-arena coordination required."),
    RFVenue(name: "Rogers Place",                type: "Arena",                  capacity: 18500,  city: "Edmonton, Canada",         region: "CA", rfEnv: .busy,      notes: "Modern arena with extensive in-house systems and guest-device density."),
    RFVenue(name: "Pacific Coliseum",            type: "Arena",                  capacity: 15000,  city: "Vancouver, Canada",        region: "CA", rfEnv: .busy,      notes: "Older building with moderate multipath and event-day wireless density."),
    RFVenue(name: "Rogers Arena",                type: "Arena",                  capacity: 19000,  city: "Vancouver, Canada",        region: "CA", rfEnv: .veryBusy,  notes: "Dense downtown environment and strong in-house infrastructure make this a busy coordination room."),

    // MARK: - Major US stadiums
    RFVenue(name: "SoFi Stadium",                type: "Stadium",                capacity: 70000,  city: "Inglewood, CA",            region: "US", rfEnv: .veryBusy,  notes: "Extremely dense DAS, Wi-Fi, broadcast, and event systems. One of the most complex RF environments in live entertainment."),
    RFVenue(name: "Levi's Stadium",              type: "Stadium",                capacity: 68000,  city: "Santa Clara, CA",          region: "US", rfEnv: .veryBusy,  notes: "Major stadium with robust DAS and fan Wi-Fi. Extensive pre-coordination needed."),
    RFVenue(name: "Rose Bowl",                   type: "Stadium",                capacity: 90000,  city: "Pasadena, CA",             region: "US", rfEnv: .veryBusy,  notes: "Large open stadium with long throw distances and high event-day system density."),
    RFVenue(name: "Dodger Stadium",              type: "Stadium",                capacity: 56000,  city: "Los Angeles, CA",          region: "US", rfEnv: .veryBusy,  notes: "Large open-air urban venue with extensive house systems and guest devices."),
    RFVenue(name: "Petco Park",                  type: "Stadium",                capacity: 40000,  city: "San Diego, CA",             region: "US", rfEnv: .busy,      notes: "Open-air ballpark with dense downtown RF but generally favorable line-of-sight."),
    RFVenue(name: "Coors Field",                 type: "Stadium",                capacity: 50000,  city: "Denver, CO",               region: "US", rfEnv: .busy,      notes: "Large open stadium with broad fan-device use and standard broadcast infrastructure."),
    RFVenue(name: "Empower Field at Mile High",  type: "Stadium",                capacity: 76000,  city: "Denver, CO",               region: "US", rfEnv: .veryBusy,  notes: "NFL-scale DAS, broadcast, and guest Wi-Fi systems require major coordination."),
    RFVenue(name: "Camping World Stadium",       type: "Stadium",                capacity: 65000,  city: "Orlando, FL",              region: "US", rfEnv: .veryBusy,  notes: "Large open-air event venue with festival-scale and stadium-scale wireless demands."),
    RFVenue(name: "Hard Rock Stadium",           type: "Stadium",                capacity: 65000,  city: "Miami Gardens, FL",        region: "US", rfEnv: .veryBusy,  notes: "NFL-scale venue with strong DAS, Wi-Fi, and broadcast activity."),
    RFVenue(name: "Mercedes-Benz Stadium",       type: "Stadium",                capacity: 71000,  city: "Atlanta, GA",              region: "US", rfEnv: .veryBusy,  notes: "Heavy digital infrastructure and one of the busiest in-house wireless ecosystems in touring."),
    RFVenue(name: "State Farm Arena",            type: "Arena",                  capacity: 17500,  city: "Atlanta, GA",              region: "US", rfEnv: .veryBusy,  notes: "Downtown arena with dense event-day guest and house-system wireless load."),
    RFVenue(name: "United Center Pavilion Lot Stage", type: "Outdoor Festival Stage", capacity: 25000, city: "Chicago, IL",         region: "US", rfEnv: .busy,      notes: "Festival-style temporary staging near a major arena campus. Coordination with house and surrounding systems advised."),
    RFVenue(name: "Wrigley Field",               type: "Stadium",                capacity: 41000,  city: "Chicago, IL",              region: "US", rfEnv: .veryBusy,  notes: "Urban ballpark with difficult surrounding RF environment and heavy event-day density."),
    RFVenue(name: "Soldier Field",               type: "Stadium",                capacity: 61000,  city: "Chicago, IL",              region: "US", rfEnv: .veryBusy,  notes: "Major NFL venue with DAS, Wi-Fi, and broadcast systems active across the bowl."),
    RFVenue(name: "Lucas Oil Stadium",           type: "Stadium",                capacity: 67000,  city: "Indianapolis, IN",         region: "US", rfEnv: .veryBusy,  notes: "Large domed stadium with significant indoor reflections and dense event-day systems."),
    RFVenue(name: "Kauffman Stadium",            type: "Stadium",                capacity: 37000,  city: "Kansas City, MO",          region: "US", rfEnv: .busy,      notes: "Open-air ballpark with moderate RF pressure and favorable line-of-sight."),
    RFVenue(name: "Allegiant Stadium",           type: "Stadium",                capacity: 65000,  city: "Las Vegas, NV",            region: "US", rfEnv: .veryBusy,  notes: "High-density indoor stadium with massive DAS, Wi-Fi, and event infrastructure."),
    RFVenue(name: "Caesars Superdome",           type: "Domed Stadium",          capacity: 73000,  city: "New Orleans, LA",          region: "US", rfEnv: .veryBusy,  notes: "Indoor NFL-scale environment with strong multipath and massive in-building systems."),
    RFVenue(name: "Yankee Stadium",              type: "Stadium",                capacity: 46000,  city: "Bronx, NY",                region: "US", rfEnv: .veryBusy,  notes: "Dense NYC RF environment and heavy event-day production infrastructure."),
    RFVenue(name: "Citi Field",                  type: "Stadium",                capacity: 42000,  city: "Queens, NY",               region: "US", rfEnv: .veryBusy,  notes: "Large urban ballpark with strong guest-device and stadium-system load."),
    RFVenue(name: "MetLife Stadium",             type: "Stadium",                capacity: 82000,  city: "East Rutherford, NJ",       region: "US", rfEnv: .veryBusy,  notes: "One of the most demanding large-stadium RF environments in North America."),
    RFVenue(name: "Barclays Center",             type: "Arena",                  capacity: 17000,  city: "Brooklyn, NY",             region: "US", rfEnv: .veryBusy,  notes: "Dense urban environment with major in-house wireless and show-day complexity."),
    RFVenue(name: "Highmark Stadium",            type: "Stadium",                capacity: 70000,  city: "Orchard Park, NY",          region: "US", rfEnv: .busy,      notes: "Open-air stadium with long field distances and dense event-day guest/device traffic."),
    RFVenue(name: "Bank of America Stadium",     type: "Stadium",                capacity: 74000,  city: "Charlotte, NC",            region: "US", rfEnv: .veryBusy,  notes: "NFL-scale venue with major DAS and house wireless infrastructure."),
    RFVenue(name: "Progressive Field",           type: "Stadium",                capacity: 35000,  city: "Cleveland, OH",            region: "US", rfEnv: .busy,      notes: "Open-air urban ballpark with manageable but busy event-day wireless conditions."),
    RFVenue(name: "Paycor Stadium",              type: "Stadium",                capacity: 65000,  city: "Cincinnati, OH",           region: "US", rfEnv: .veryBusy,  notes: "Large stadium with extensive in-house systems and broad coverage requirements."),
    RFVenue(name: "Lincoln Financial Field",     type: "Stadium",                capacity: 68000,  city: "Philadelphia, PA",         region: "US", rfEnv: .veryBusy,  notes: "NFL-scale stadium with substantial DAS/Wi-Fi and broadcast presence."),
    RFVenue(name: "PNC Park",                    type: "Stadium",                capacity: 38000,  city: "Pittsburgh, PA",           region: "US", rfEnv: .busy,      notes: "Open-air venue with favorable line-of-sight and moderate urban RF pressure."),
    RFVenue(name: "Acrisure Stadium",            type: "Stadium",                capacity: 68000,  city: "Pittsburgh, PA",           region: "US", rfEnv: .veryBusy,  notes: "Large stadium with strong event-day wireless demands and broad coverage needs."),
    RFVenue(name: "Nissan Stadium",              type: "Stadium",                capacity: 69000,  city: "Nashville, TN",            region: "US", rfEnv: .veryBusy,  notes: "Dense event-day RF load in a major touring market."),
    RFVenue(name: "AT&T Stadium",                type: "Domed Stadium",          capacity: 80000,  city: "Arlington, TX",            region: "US", rfEnv: .veryBusy,  notes: "Massive indoor venue with complex reflections and extremely dense in-house systems."),
    RFVenue(name: "Globe Life Field",            type: "Stadium",                capacity: 40000,  city: "Arlington, TX",            region: "US", rfEnv: .busy,      notes: "Modern retractable-roof venue with strong internal wireless and guest-device load."),
    RFVenue(name: "NRG Stadium",                 type: "Stadium",                capacity: 72000,  city: "Houston, TX",              region: "US", rfEnv: .veryBusy,  notes: "Large domed stadium with strong DAS/Wi-Fi and broad in-building system overlap."),
    RFVenue(name: "Minute Maid Park",            type: "Stadium",                capacity: 41000,  city: "Houston, TX",              region: "US", rfEnv: .busy,      notes: "Retractable-roof urban ballpark with standard major-market coordination needs."),
    RFVenue(name: "Lumen Field",                 type: "Stadium",                capacity: 68000,  city: "Seattle, WA",              region: "US", rfEnv: .veryBusy,  notes: "Large stadium with strong in-house systems and a very active downtown device environment."),
    RFVenue(name: "T-Mobile Park",               type: "Stadium",                capacity: 47000,  city: "Seattle, WA",              region: "US", rfEnv: .busy,      notes: "Retractable-roof ballpark with extensive guest-device and stadium-system coverage needs."),
    RFVenue(name: "Lambeau Field",               type: "Stadium",                capacity: 81000,  city: "Green Bay, WI",            region: "US", rfEnv: .busy,      notes: "Large open-air NFL venue with long-throw coverage requirements and substantial event-day systems."),
    RFVenue(name: "American Family Field",       type: "Stadium",                capacity: 41000,  city: "Milwaukee, WI",            region: "US", rfEnv: .busy,      notes: "Retractable-roof ballpark with broad guest-device and in-house wireless coverage."),

    // MARK: - Major Canadian stadiums 
    RFVenue(name: "BC Place",                    type: "Domed Stadium",          capacity: 54000,  city: "Vancouver, Canada",        region: "CA", rfEnv: .veryBusy,  notes: "Large indoor stadium with significant multipath, DAS, and fan Wi-Fi systems."),
    RFVenue(name: "Commonwealth Stadium",        type: "Stadium",                capacity: 56000,  city: "Edmonton, Canada",         region: "CA", rfEnv: .veryBusy,  notes: "Large outdoor stadium with long coverage distances and substantial event-day infrastructure."),
    RFVenue(name: "Olympic Stadium",             type: "Domed Stadium",          capacity: 56000,  city: "Montreal, Canada",         region: "CA", rfEnv: .veryBusy,  notes: "Large enclosed stadium with strong reflections and major coordination requirements."),
    RFVenue(name: "Percival Molson Memorial Stadium", type: "Stadium",          capacity: 25000,  city: "Montreal, Canada",         region: "CA", rfEnv: .busy,      notes: "Urban open-air stadium with moderate-to-heavy event-day RF load."),
    RFVenue(name: "BMO Field",                   type: "Stadium",                capacity: 30000,  city: "Toronto, Canada",          region: "CA", rfEnv: .veryBusy,  notes: "Dense city venue district and high event-day wireless density."),
    RFVenue(name: "Tim Hortons Field",           type: "Stadium",                capacity: 24000,  city: "Hamilton, Canada",         region: "CA", rfEnv: .busy,      notes: "Modern mid-size stadium with standard event-day wireless needs."),
    RFVenue(name: "Mosaic Stadium",              type: "Stadium",                capacity: 33000,  city: "Regina, Canada",           region: "CA", rfEnv: .busy,      notes: "Large prairie stadium with long field coverage needs and solid line-of-sight."),
    RFVenue(name: "McMahon Stadium",             type: "Stadium",                capacity: 35000,  city: "Calgary, Canada",          region: "CA", rfEnv: .busy,      notes: "Open-air football venue with moderate-to-heavy event-day systems."),
    RFVenue(name: "IG Field",                    type: "Stadium",                capacity: 33000,  city: "Winnipeg, Canada",         region: "CA", rfEnv: .busy,      notes: "Modern football stadium with broad coverage needs and standard stadium DAS/Wi-Fi profile."),

    // MARK: - Major US amphitheaters / outdoor music venues 
    RFVenue(name: "The Gorge Amphitheatre",      type: "Outdoor Amphitheater",   capacity: 27000,  city: "George, WA",               region: "US", rfEnv: .moderate,  notes: "Excellent line-of-sight in open air, but very large audience area requires careful antenna strategy."),
    RFVenue(name: "Hollywood Bowl",              type: "Outdoor Amphitheater",   capacity: 17500,  city: "Los Angeles, CA",          region: "US", rfEnv: .busy,      notes: "Major LA RF market with heavy production density and reflective shell/stage environment."),
    RFVenue(name: "Greek Theatre",               type: "Outdoor Amphitheater",   capacity: 5800,   city: "Los Angeles, CA",          region: "US", rfEnv: .moderate,  notes: "Smaller hillside amphitheater with generally workable RF and manageable coverage distances."),
    RFVenue(name: "Shoreline Amphitheatre",      type: "Outdoor Amphitheater",   capacity: 22000,  city: "Mountain View, CA",        region: "US", rfEnv: .busy,      notes: "Large Bay Area outdoor venue with moderate regional RF pressure."),
    RFVenue(name: "Toyota Amphitheatre",         type: "Outdoor Amphitheater",   capacity: 18000,  city: "Wheatland, CA",            region: "US", rfEnv: .moderate,  notes: "Open-air shed with relatively favorable RF conditions and long but manageable coverage paths."),
    RFVenue(name: "MidFlorida Credit Union Amphitheatre", type: "Outdoor Amphitheater", capacity: 20000, city: "Tampa, FL", region: "US", rfEnv: .busy,      notes: "Large shed with broad lawn coverage and typical regional RF activity."),
    RFVenue(name: "Ameris Bank Amphitheatre",    type: "Outdoor Amphitheater",   capacity: 12000,  city: "Alpharetta, GA",           region: "US", rfEnv: .busy,      notes: "Strong suburban development and guest-device density with mostly favorable line-of-sight."),
    RFVenue(name: "Credit Union 1 Amphitheatre", type: "Outdoor Amphitheater",   capacity: 28000,  city: "Tinley Park, IL",           region: "US", rfEnv: .busy,      notes: "Large lawn shed requiring broad antenna coverage and coordination with touring systems."),
    RFVenue(name: "Ruoff Music Center",          type: "Outdoor Amphitheater",   capacity: 24000,  city: "Noblesville, IN",           region: "US", rfEnv: .busy,      notes: "Large outdoor shed with broad audience coverage needs and major touring use."),
    RFVenue(name: "Starlight Theatre",           type: "Outdoor Theatre",        capacity: 8000,   city: "Kansas City, MO",          region: "US", rfEnv: .moderate,  notes: "Open-air theatre with generally favorable RF, though nearby urban infrastructure can raise the floor."),
    RFVenue(name: "PNC Music Pavilion",          type: "Outdoor Amphitheater",   capacity: 19000,  city: "Charlotte, NC",            region: "US", rfEnv: .busy,      notes: "Large amphitheater with broad lawn coverage and moderate metro RF pressure."),
    RFVenue(name: "Blossom Music Center",        type: "Outdoor Amphitheater",   capacity: 19000,  city: "Cuyahoga Falls, OH",       region: "US", rfEnv: .moderate,  notes: "Open park setting with good RF behavior and wide audience area."),
    RFVenue(name: "Merriweather Post Pavilion",  type: "Outdoor Amphitheater",   capacity: 19000,  city: "Columbia, MD",             region: "US", rfEnv: .busy,      notes: "Strong regional market and guest-device density with otherwise favorable open-air RF conditions."),
    RFVenue(name: "The Pavilion at Star Lake",   type: "Outdoor Amphitheater",   capacity: 23000,  city: "Burgettstown, PA",         region: "US", rfEnv: .moderate,  notes: "Large outdoor venue with broad throw distances and generally cooperative spectrum."),
    RFVenue(name: "Freedom Mortgage Pavilion",   type: "Outdoor Amphitheater",   capacity: 25000,  city: "Camden, NJ",               region: "US", rfEnv: .veryBusy,  notes: "Dense northeast urban environment across the river from Philadelphia with heavy show-day RF load."),
    RFVenue(name: "Ascend Amphitheater",         type: "Outdoor Amphitheater",   capacity: 6800,   city: "Nashville, TN",            region: "US", rfEnv: .busy,      notes: "Downtown riverfront site with strong urban RF activity and dense audience device usage."),
    RFVenue(name: "Germania Insurance Amphitheater", type: "Outdoor Amphitheater", capacity: 14000, city: "Austin, TX",              region: "US", rfEnv: .busy,      notes: "Festival-friendly outdoor venue with nearby motorsport/event infrastructure."),
    RFVenue(name: "Dos Equis Pavilion",          type: "Outdoor Amphitheater",   capacity: 20000,  city: "Dallas, TX",               region: "US", rfEnv: .busy,      notes: "Large urban shed with standard metropolitan RF pressure."),
    RFVenue(name: "White River Amphitheatre",    type: "Outdoor Amphitheater",   capacity: 20000,  city: "Auburn, WA",               region: "US", rfEnv: .moderate,  notes: "Open-air venue with good line-of-sight and broad lawn coverage requirements."),
    RFVenue(name: "Alpine Valley Music Theatre", type: "Outdoor Amphitheater",   capacity: 35000,  city: "East Troy, WI",            region: "US", rfEnv: .moderate,  notes: "Very large outdoor venue with long coverage distances and generally favorable rural RF conditions."),

    // MARK: - Major Canadian amphitheaters / outdoor venues 
    RFVenue(name: "RBC Amphitheatre",            type: "Outdoor Amphitheater",   capacity: 16000,  city: "Toronto, Canada",          region: "CA", rfEnv: .veryBusy,  notes: "Major Toronto waterfront venue with dense downtown/waterfront RF conditions and high guest-device load."),
    RFVenue(name: "Budweiser Stage Grounds",     type: "Outdoor Festival Stage", capacity: 18000,  city: "Toronto, Canada",          region: "CA", rfEnv: .veryBusy,  notes: "Dense Toronto waterfront RF environment. Coordination with nearby venue infrastructure is important."),
    RFVenue(name: "Badlands Amphitheatre",       type: "Outdoor Amphitheater",   capacity: 2500,   city: "Drumheller, Canada",       region: "CA", rfEnv: .low,       notes: "Natural amphitheater with open sky and excellent RF line-of-sight. Minimal urban congestion."),
    RFVenue(name: "Molson Canadian Centre at Casino New Brunswick", type: "Outdoor Amphitheater", capacity: 10000, city: "Moncton, Canada", region: "CA", rfEnv: .moderate, notes: "Regional amphitheater with manageable RF conditions and moderate local systems."),
    RFVenue(name: "Festival d'été Main Plains Stage", type: "Outdoor Festival Stage", capacity: 80000, city: "Quebec City, Canada", region: "CA", rfEnv: .veryBusy, notes: "Large festival deployment with dense multi-stage and city-center coordination needs."),

    // MARK: - Major US theatres / concert halls / PACs 
    RFVenue(name: "Radio City Music Hall",       type: "Theatre",                capacity: 6000,   city: "New York, NY",             region: "US", rfEnv: .veryBusy,  notes: "Dense Midtown RF environment with strong in-house and broadcast infrastructure."),
    RFVenue(name: "Beacon Theatre",              type: "Theatre",                capacity: 2800,   city: "New York, NY",             region: "US", rfEnv: .veryBusy,  notes: "Historic urban theatre with manageable interior RF but dense surrounding city spectrum."),
    RFVenue(name: "Carnegie Hall",               type: "Concert Hall",           capacity: 2800,   city: "New York, NY",             region: "US", rfEnv: .busy,      notes: "Historic hall with heavy patron device density but generally predictable RF indoors."),
    RFVenue(name: "David Geffen Hall",           type: "Concert Hall",           capacity: 2200,   city: "New York, NY",             region: "US", rfEnv: .busy,      notes: "Modernized hall with standard Manhattan congestion and strong in-house AV support."),
    RFVenue(name: "The Met Philadelphia",        type: "Historic Theater",       capacity: 3500,   city: "Philadelphia, PA",         region: "US", rfEnv: .busy,      notes: "Large restored theatre with strong city RF density and typical touring wireless needs."),
    RFVenue(name: "Miller Theater",              type: "Theatre",                capacity: 2800,   city: "Philadelphia, PA",         region: "US", rfEnv: .busy,      notes: "Historic room with moderate urban RF load and manageable interior behavior."),
    RFVenue(name: "Kennedy Center Opera House",  type: "Performing Arts Center", capacity: 2300,   city: "Washington, DC",           region: "US", rfEnv: .busy,      notes: "Large arts complex with multiple simultaneous productions and dense building systems."),
    RFVenue(name: "Kennedy Center Concert Hall", type: "Concert Hall",           capacity: 2500,   city: "Washington, DC",           region: "US", rfEnv: .busy,      notes: "Large hall within a complex arts center. Coordinate with house systems and neighboring halls."),
    RFVenue(name: "The Chicago Theatre",         type: "Historic Theater",       capacity: 3600,   city: "Chicago, IL",              region: "US", rfEnv: .veryBusy,  notes: "Dense downtown RF environment with strong guest-device load."),
    RFVenue(name: "Auditorium Theatre",          type: "Historic Theater",       capacity: 3900,   city: "Chicago, IL",              region: "US", rfEnv: .busy,      notes: "Large historic hall with predictable indoor RF and moderate downtown congestion."),
    RFVenue(name: "Walt Disney Concert Hall",    type: "Concert Hall",           capacity: 2200,   city: "Los Angeles, CA",          region: "US", rfEnv: .busy,      notes: "Complex architecture and downtown density call for careful antenna placement."),
    RFVenue(name: "Dolby Theatre",               type: "Theatre",                capacity: 3300,   city: "Hollywood, CA",            region: "US", rfEnv: .veryBusy,  notes: "Broadcast-heavy theatre in a dense entertainment district."),
    RFVenue(name: "Pantages Theatre",            type: "Historic Theater",       capacity: 2700,   city: "Los Angeles, CA",          region: "US", rfEnv: .busy,      notes: "Strong surrounding RF activity but manageable indoor coordination."),
    RFVenue(name: "Fox Theatre Atlanta",         type: "Historic Theater",       capacity: 4600,   city: "Atlanta, GA",              region: "US", rfEnv: .busy,      notes: "Large historic theatre in a busy downtown environment."),
    RFVenue(name: "Adrienne Arsht Center",       type: "Performing Arts Center", capacity: 2400,   city: "Miami, FL",                region: "US", rfEnv: .busy,      notes: "Multi-hall PAC with moderate-to-heavy urban RF conditions."),
    RFVenue(name: "Broward Center",              type: "Performing Arts Center", capacity: 2700,   city: "Fort Lauderdale, FL",      region: "US", rfEnv: .moderate,  notes: "Large PAC with manageable coordination and moderate regional RF density."),
    RFVenue(name: "Saenger Theatre",             type: "Historic Theater",       capacity: 2600,   city: "New Orleans, LA",          region: "US", rfEnv: .busy,      notes: "Downtown venue with moderate urban congestion and historic interior reflections."),
    RFVenue(name: "The Fabulous Fox",            type: "Historic Theater",       capacity: 4500,   city: "St. Louis, MO",            region: "US", rfEnv: .busy,      notes: "Large historic theatre with city-center RF density and wide indoor coverage needs."),
    RFVenue(name: "Bass Concert Hall",           type: "Concert Hall",           capacity: 2900,   city: "Austin, TX",               region: "US", rfEnv: .moderate,  notes: "University-affiliated hall with moderate local congestion and predictable indoor behavior."),
    RFVenue(name: "Majestic Theatre",            type: "Historic Theater",       capacity: 2200,   city: "San Antonio, TX",          region: "US", rfEnv: .moderate,  notes: "Historic downtown theatre with manageable RF environment."),
    RFVenue(name: "Meyerson Symphony Center",    type: "Concert Hall",           capacity: 2100,   city: "Dallas, TX",               region: "US", rfEnv: .busy,      notes: "Urban arts district hall with moderate city RF density."),
    RFVenue(name: "Jones Hall",                  type: "Concert Hall",           capacity: 2900,   city: "Houston, TX",              region: "US", rfEnv: .busy,      notes: "Large urban hall with moderate house-system and patron-device load."),
    RFVenue(name: "Benaroya Hall",               type: "Concert Hall",           capacity: 2500,   city: "Seattle, WA",              region: "US", rfEnv: .busy,      notes: "Downtown concert hall with moderate city RF and generally stable indoor operation."),
    RFVenue(name: "Paramount Theatre",           type: "Historic Theater",       capacity: 2800,   city: "Seattle, WA",              region: "US", rfEnv: .busy,      notes: "Downtown historic room with moderate guest-device and urban spectrum pressure."),

    // MARK: - Major Canadian theatres / concert halls / PACs 
    RFVenue(name: "Royal Alexandra Theatre",     type: "Historic Theater",       capacity: 1240,   city: "Toronto, Canada",          region: "CA", rfEnv: .busy,      notes: "Historic downtown theatre in a dense entertainment district."),
    RFVenue(name: "Ed Mirvish Theatre",          type: "Historic Theater",       capacity: 2300,   city: "Toronto, Canada",          region: "CA", rfEnv: .busy,      notes: "Large downtown theatre with strong patron-device density and surrounding city RF activity."),
    RFVenue(name: "Princess of Wales Theatre",   type: "Theatre",                capacity: 2000,   city: "Toronto, Canada",          region: "CA", rfEnv: .busy,      notes: "Major downtown theatre with modern systems and typical urban spectrum density."),
    RFVenue(name: "Massey Hall",                 type: "Concert Hall",           capacity: 2700,   city: "Toronto, Canada",          region: "CA", rfEnv: .busy,      notes: "Historic room with significant patron-device presence and careful indoor antenna needs."),
    RFVenue(name: "Meridian Hall",               type: "Performing Arts Center", capacity: 3000,   city: "Toronto, Canada",          region: "CA", rfEnv: .busy,      notes: "Large downtown hall with manageable indoor RF and dense nearby building activity."),
    RFVenue(name: "Roy Thomson Hall",            type: "Concert Hall",           capacity: 2600,   city: "Toronto, Canada",          region: "CA", rfEnv: .busy,      notes: "Glass-heavy downtown environment and strong patron-device density."),
    RFVenue(name: "National Arts Centre",        type: "Performing Arts Center", capacity: 2300,   city: "Ottawa, Canada",           region: "CA", rfEnv: .moderate,  notes: "Multi-hall arts complex with moderate government-district RF pressure."),
    RFVenue(name: "Confederation Centre of the Arts", type: "Performing Arts Center", capacity: 1100, city: "Charlottetown, Canada", region: "CA", rfEnv: .low,       notes: "Regional PAC with comparatively clean RF conditions and manageable coordination."),
    RFVenue(name: "Queen Elizabeth Theatre",     type: "Theatre",                capacity: 2800,   city: "Vancouver, Canada",        region: "CA", rfEnv: .busy,      notes: "Downtown performing arts venue with moderate urban RF density."),
    RFVenue(name: "Orpheum Theatre Vancouver",   type: "Historic Theater",       capacity: 2700,   city: "Vancouver, Canada",        region: "CA", rfEnv: .busy,      notes: "Historic downtown hall with predictable indoor RF and moderate city congestion."),
    RFVenue(name: "Winspear Centre",             type: "Concert Hall",           capacity: 1900,   city: "Edmonton, Canada",         region: "CA", rfEnv: .moderate,  notes: "Concert hall environment with moderate urban RF density and stable indoor coordination."),
    RFVenue(name: "Southern Alberta Jubilee Auditorium", type: "Performing Arts Center", capacity: 2500, city: "Calgary, Canada", region: "CA", rfEnv: .moderate, notes: "Large auditorium with manageable RF and moderate surrounding congestion."),
    RFVenue(name: "Northern Alberta Jubilee Auditorium", type: "Performing Arts Center", capacity: 2500, city: "Edmonton, Canada", region: "CA", rfEnv: .moderate, notes: "Large arts venue with stable indoor RF behavior."),
    RFVenue(name: "Salle Wilfrid-Pelletier",     type: "Performing Arts Center", capacity: 3000,   city: "Montreal, Canada",         region: "CA", rfEnv: .busy,      notes: "Large arts hall within a dense multi-venue complex."),
    RFVenue(name: "Place des Festivals Main Stage", type: "Outdoor Festival Stage", capacity: 50000, city: "Montreal, Canada",       region: "CA", rfEnv: .veryBusy,  notes: "Festival deployment in dense downtown Montreal. Multi-stage and public-device congestion can be substantial.")
]
// MARK: - Wireless Systems
let rfWirelessSystems: [RFWirelessSystem] = [
    RFWirelessSystem(
        key: "shure-axient", brand: "Shure", system: "Axient Digital",
        freqBands: [
            "US": [FreqBand(band: "G57", range: "470–638 MHz"), FreqBand(band: "H60", range: "542–616 MHz"), FreqBand(band: "V60", range: "596–688 MHz")],
            "EU": [FreqBand(band: "R16", range: "655–679 MHz"), FreqBand(band: "S50", range: "823–865 MHz")],
            "AU": [FreqBand(band: "P10", range: "614–694 MHz")],
            "CA": [FreqBand(band: "G50", range: "470–534 MHz"), FreqBand(band: "H50", range: "534–598 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Shure AD4Q Axient Digital (4ch)", channels: 4, cat: "Receiver"),
            RFRxModel(name: "Shure AD4D Axient Digital (2ch)", channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Shure AD2 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Shure AD1 Bodypack Transmitter", cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Shure P10T PSM1000 IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Shure P10R PSM1000 IEM Receiver",    cat: "IEM Receiver")],
        coord: "Shure Wireless Workbench 6"
    ),
    RFWirelessSystem(
        key: "shure-ulxd", brand: "Shure", system: "ULX-D",
        freqBands: [
            "US": [FreqBand(band: "G50", range: "470–534 MHz"), FreqBand(band: "H50", range: "534–598 MHz"), FreqBand(band: "J50A", range: "572–636 MHz")],
            "EU": [FreqBand(band: "V50", range: "174–216 MHz"), FreqBand(band: "X52", range: "902–928 MHz")],
            "AU": [FreqBand(band: "L50", range: "632–696 MHz")],
            "CA": [FreqBand(band: "G50", range: "470–534 MHz"), FreqBand(band: "H50", range: "534–598 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Shure ULXD4Q Quad Receiver (4ch)", channels: 4, cat: "Receiver"),
            RFRxModel(name: "Shure ULXD4D Dual Receiver (2ch)",  channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Shure ULXD2 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Shure ULXD1 Bodypack Transmitter",  cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Shure P9T PSM900 IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Shure P9R PSM900 IEM Receiver",    cat: "IEM Receiver")],
        coord: "Shure Wireless Workbench 6"
    ),
    RFWirelessSystem(
        key: "sennheiser-ew6000", brand: "Sennheiser", system: "EW 6000",
        freqBands: [
            "US": [FreqBand(band: "A1", range: "470–516 MHz"), FreqBand(band: "A", range: "516–558 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "EU": [FreqBand(band: "A", range: "516–558 MHz"), FreqBand(band: "G", range: "566–608 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "AU": [FreqBand(band: "D", range: "780–822 MHz")],
            "CA": [FreqBand(band: "A1", range: "470–516 MHz"), FreqBand(band: "A", range: "516–558 MHz")],
        ],
        receivers: [RFRxModel(name: "Sennheiser EM 6000 Dante (2ch)", channels: 2, cat: "Receiver")],
        handhelds: [RFTxItem(name: "Sennheiser SKM 6000 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Sennheiser SK 6000 Bodypack Transmitter",  cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Sennheiser SR IEM G4 Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Sennheiser EK IEM G4 Receiver",    cat: "IEM Receiver")],
        coord: "Sennheiser Wireless Systems Manager (WSM)"
    ),
    RFWirelessSystem(
        key: "sennheiser-g4", brand: "Sennheiser", system: "Evolution Wireless G4",
        freqBands: [
            "US": [FreqBand(band: "A1", range: "470–516 MHz"), FreqBand(band: "A", range: "516–558 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "EU": [FreqBand(band: "G", range: "566–608 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "AU": [FreqBand(band: "D", range: "780–822 MHz")],
            "CA": [FreqBand(band: "A1", range: "470–516 MHz")],
        ],
        receivers: [RFRxModel(name: "Sennheiser EM 300-500 G4 (2ch)", channels: 2, cat: "Receiver")],
        handhelds: [RFTxItem(name: "Sennheiser SKM 300 G4 Handheld", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Sennheiser SK 300 G4 Bodypack",   cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Sennheiser SR IEM G4 Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Sennheiser EK IEM G4 Receiver",    cat: "IEM Receiver")],
        coord: "Sennheiser Wireless Systems Manager (WSM)"
    ),
    RFWirelessSystem(
        key: "wisycom", brand: "Wisycom", system: "MCR54 / MTP41S",
        freqBands: [
            "US": [FreqBand(band: "A5T", range: "470–558 MHz"), FreqBand(band: "B5T", range: "554–640 MHz"), FreqBand(band: "C5T", range: "636–722 MHz")],
            "EU": [FreqBand(band: "A5T", range: "470–558 MHz"), FreqBand(band: "B5T", range: "554–640 MHz")],
            "AU": [FreqBand(band: "B5T", range: "554–640 MHz")],
            "CA": [FreqBand(band: "A5T", range: "470–558 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Wisycom MCR54 Quad Receiver (4ch)",  channels: 4, cat: "Receiver"),
            RFRxModel(name: "Wisycom MCR42S Dual Receiver (2ch)", channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Wisycom MTH400 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Wisycom MTP41S Bodypack Transmitter",  cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Wisycom MTK952 IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Wisycom MPR52 IEM Receiver",     cat: "IEM Receiver")],
        coord: "IAS Intermodulation Analysis System"
    ),
    RFWirelessSystem(
        key: "audio-technica", brand: "Audio-Technica", system: "5000 Series",
        freqBands: [
            "US": [FreqBand(band: "TV56", range: "542–572 MHz"), FreqBand(band: "TV62", range: "578–608 MHz")],
            "EU": [FreqBand(band: "EG1", range: "470–530 MHz"), FreqBand(band: "EG2", range: "530–590 MHz")],
            "AU": [FreqBand(band: "AU",  range: "520–554 MHz")],
            "CA": [FreqBand(band: "TV56", range: "542–572 MHz")],
        ],
        receivers: [RFRxModel(name: "Audio-Technica ATW-R5220 (2ch)", channels: 2, cat: "Receiver")],
        handhelds: [RFTxItem(name: "Audio-Technica ATW-T5202 Handheld", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Audio-Technica ATW-T5201 Bodypack",  cat: "Bodypack / Lav")],
        iemTx: nil,
        iemRx: nil,
        coord: "Audio-Technica ATND1061DAN Network Manager"
    ),
    RFWirelessSystem(
        key: "lectrosonics", brand: "Lectrosonics", system: "Venue2 / D Squared",
        freqBands: [
            "US": [FreqBand(band: "Block 470", range: "470–537 MHz"), FreqBand(band: "Block 19", range: "486–512 MHz"), FreqBand(band: "Block 21", range: "518–544 MHz"), FreqBand(band: "Block 22", range: "530–556 MHz")],
            "EU": [FreqBand(band: "EU1", range: "563–614 MHz"), FreqBand(band: "EU2", range: "614–663 MHz")],
            "AU": [FreqBand(band: "AUS", range: "520–614 MHz")],
            "CA": [FreqBand(band: "Block 470", range: "470–537 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Lectrosonics Venue2 (6ch frame)", channels: 6, cat: "Receiver"),
            RFRxModel(name: "Lectrosonics DCR822 (2ch)",        channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Lectrosonics DHu Digital Handheld",   cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Lectrosonics SMWB Bodypack Transmitter", cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Lectrosonics M2T IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Lectrosonics M2R IEM Receiver",    cat: "IEM Receiver")],
        coord: "IAS Intermodulation Analysis System"
    ),
    RFWirelessSystem(
        key: "sound-devices", brand: "Sound Devices", system: "A20 Series",
        freqBands: [
            "US": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
            "EU": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
            "AU": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
            "CA": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
        ],
        receivers: [
            RFRxModel(name: "Sound Devices A20-Nexus (8ch)", channels: 8, cat: "Receiver"),
            RFRxModel(name: "Sound Devices A20-RX (2ch)",    channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Sound Devices A20-TX Bodypack (no handheld)", cat: "Bodypack / Lav")],
        bodypacks: [RFTxItem(name: "Sound Devices A20-Mini Bodypack", cat: "Bodypack / Lav")],
        iemTx: nil,
        iemRx: nil,
        coord: "Sound Devices A20-Nexus Network App"
    ),
]

// MARK: - Antennas
let rfAntennas: [RFListItem] = [
    RFListItem(name: "RF Venue DIVERSITY FIN Antenna",        cat: "Antenna"),
    RFListItem(name: "Shure UA874US Active Cardioid Antenna", cat: "Antenna"),
    RFListItem(name: "Shure UA870US Active Omni Antenna",     cat: "Antenna"),
    RFListItem(name: "Wisycom LFA Log-Periodic Antenna",      cat: "Antenna"),
    RFListItem(name: "Lectrosonics ALP690 Log-Periodic",      cat: "Antenna"),
    RFListItem(name: "RF Venue CP Beam Circ. Polarized",      cat: "Antenna"),
    RFListItem(name: "PWS UHF Helical Antenna",               cat: "Antenna"),
]

// MARK: - Distros
let rfDistros: [RFListItem] = [
    RFListItem(name: "Shure UA845SWB 4-Way Active Distro",          cat: "Antenna Distribution"),
    RFListItem(name: "RF Venue DISTRO4 4-ch Distro",                cat: "Antenna Distribution"),
    RFListItem(name: "Lectrosonics UMCWBD-L Antenna Multicoupler",  cat: "Antenna Distribution"),
    RFListItem(name: "Professional Wireless Systems PS-RF-1 Distro", cat: "Antenna Distribution"),
    RFListItem(name: "Wisycom BFA Active Antenna Distributor",       cat: "Antenna Distribution"),
]

// MARK: - Accessories
let rfAccessories: [RFListItem] = [
    RFListItem(name: "Shure SBC850 Networked Multi-Bay Charger",      cat: "Accessory"),
    RFListItem(name: "Pelican 1630 RF Gear Transport Case",            cat: "Accessory"),
    RFListItem(name: "RG8X Low-Loss Coax Cable (100 ft)",             cat: "Accessory"),
    RFListItem(name: "BNC Male-to-Male Barrel Adapters (×10)",        cat: "Accessory"),
    RFListItem(name: "Neutrik BNC Chassis Connectors (×4)",           cat: "Accessory"),
    RFListItem(name: "Catapult CAT5 RF-over-Cat5 System (2ch)",       cat: "Accessory"),
    RFListItem(name: "Professional Wireless Systems PWS-ADII Combo",  cat: "Antenna Distribution"),
]

// MARK: - Generator helpers
func rfPick<T>(_ arr: [T]) -> T { arr[Int.random(in: 0..<arr.count)] }
// MARK: - Production Advance

struct RFPerformerEntry: Identifiable {
    let id: UUID = UUID()
    var name: String
    var role: String
    var location: String      // e.g. "Stage Left", "FOH", "Pit"
    var wirelessChannels: Int // 0 = no wireless mic
    var wirelessType: String  // "HH", "BP", "headset", "lav"
    var iemChannels: Int      // 0 = no IEM
    var notes: String
}

struct RFProductionAdvance: Identifiable {
    let id: UUID = UUID()
    var showName: String
    var performers: [RFPerformerEntry]
    var venue: RFVenue
    var changeLog: [String]
}

// MARK: - Gear Validation

struct RFValidationResult: Identifiable {
    let id = UUID()
    var category: String
    var required: Int
    var onHand: Int
    var isOk: Bool { onHand >= required }
}

func validateGearList(gear: [RFGearItem], against advance: RFProductionAdvance) -> [RFValidationResult] {
    let totalHH    = advance.performers.reduce(0) { $0 + ($1.wirelessType == "HH" ? $1.wirelessChannels : 0) }
    let totalBP    = advance.performers.reduce(0) { $0 + ($1.wirelessType != "HH" ? $1.wirelessChannels : 0) }
    let totalIEM   = advance.performers.reduce(0) { $0 + $1.iemChannels }

    func qtyFor(_ cats: [String]) -> Int {
        gear.filter { cats.contains($0.cat) }.reduce(0) { $0 + $1.qty }
    }

    var results: [RFValidationResult] = []

    if totalHH > 0 {
        results.append(RFValidationResult(
            category: "Handheld Wireless",
            required: totalHH,
            onHand: qtyFor(["Handheld Wireless"])
        ))
    }
    if totalBP > 0 {
        results.append(RFValidationResult(
            category: "Bodypack / Lav",
            required: totalBP,
            onHand: qtyFor(["Bodypack / Lav"])
        ))
    }
    if totalIEM > 0 {
        results.append(RFValidationResult(
            category: "IEM",
            required: totalIEM * 2,   // tx + rx pairs
            onHand: qtyFor(["IEM Transmitter", "IEM Receiver"])
        ))
    }
    return results
}

// MARK: - Production Advance Generator

private let concertRoles: [(name: String, role: String, loc: String, hhCh: Int, bpCh: Int, iemCh: Int)] = [
    ("Lead Vocals",     "Lead Vocalist",    "Center Stage",  1, 0, 1),
    ("BGV 1",           "Background Vocal", "Stage Right",   1, 0, 1),
    ("BGV 2",           "Background Vocal", "Stage Left",    1, 0, 1),
    ("Guitar 1",        "Lead Guitar",      "Stage Right",   0, 1, 1),
    ("Guitar 2",        "Rhythm Guitar",    "Stage Left",    0, 1, 1),
    ("Bass",            "Bassist",          "Stage Left",    0, 1, 1),
    ("Keys",            "Keyboard",         "Upstage Right", 0, 1, 1),
    ("Drums",           "Drummer",          "Upstage",       0, 0, 1),
    ("Perc",            "Percussionist",    "Upstage Left",  0, 1, 1),
    ("MD",              "Music Director",   "Pit",           0, 0, 1),
]

private let theaterRoles: [(name: String, role: String, loc: String, hhCh: Int, bpCh: Int, iemCh: Int)] = [
    ("Lead 1",          "Lead Actor",       "Center",        0, 1, 1),
    ("Lead 2",          "Lead Actress",     "Center",        0, 1, 1),
    ("Supporting 1",    "Supporting Actor", "Stage Right",   0, 1, 0),
    ("Supporting 2",    "Supporting Actor", "Stage Left",    0, 1, 0),
    ("Supporting 3",    "Supporting Actor", "Upstage",       0, 1, 0),
    ("Swing",           "Swing/Cover",      "Wings",         0, 1, 0),
    ("Conductor",       "Conductor",        "Pit",           0, 0, 1),
    ("MD",              "Music Director",   "Pit",           0, 0, 1),
]

private let corporateRoles: [(name: String, role: String, loc: String, hhCh: Int, bpCh: Int, iemCh: Int)] = [
    ("Presenter 1",     "Keynote Speaker",  "Stage",         1, 0, 1),
    ("Presenter 2",     "Panel Moderator",  "Stage",         1, 0, 0),
    ("Panelist 1",      "Panelist",         "Table",         0, 1, 0),
    ("Panelist 2",      "Panelist",         "Table",         0, 1, 0),
    ("Panelist 3",      "Panelist",         "Table",         0, 1, 0),
    ("Emcee",           "Emcee",            "Stage",         1, 0, 1),
]

func generateProductionAdvance(venue: RFVenue) -> RFProductionAdvance {
    let pool: [(name: String, role: String, loc: String, hhCh: Int, bpCh: Int, iemCh: Int)]
    switch venue.type.lowercased() {
    case let t where t.contains("theater") || t.contains("theatre"):
        pool = theaterRoles
    case let t where t.contains("corporate") || t.contains("conference") || t.contains("convention"):
        pool = corporateRoles
    default:
        pool = concertRoles
    }

    let count = rfRand(max(3, pool.count - 3), pool.count)
    let selected = Array(rfPickN(pool, count))

    let performers: [RFPerformerEntry] = selected.map { r in
        let wType: String
        let wCh: Int
        if r.hhCh > 0 { wType = "HH"; wCh = r.hhCh }
        else if r.bpCh > 0 { wType = rfPick(["BP", "lav", "headset"]); wCh = r.bpCh }
        else { wType = "none"; wCh = 0 }

        return RFPerformerEntry(
            name: r.name,
            role: r.role,
            location: r.loc,
            wirelessChannels: wCh,
            wirelessType: wType,
            iemChannels: r.iemCh,
            notes: ""
        )
    }

    let showNames = ["Summer Tour", "World Tour", "Special Event", "Grand Opening",
                     "Annual Gala", "Season Opener", "Final Night", "World Premiere"]

    return RFProductionAdvance(
        showName: "\(venue.name) — \(rfPick(showNames))",
        performers: performers,
        venue: venue,
        changeLog: []
    )
}

func generateRehearsalChange(
    advance: RFProductionAdvance,
    iteration: Int
) -> (advance: RFProductionAdvance, description: String) {
    var updated = advance
    var desc = ""

    let changeType = rfRand(0, 2)
    switch changeType {
    case 0 where updated.performers.count > 1:
        // Remove a performer
        let idx = rfRand(0, updated.performers.count - 1)
        let removed = updated.performers.remove(at: idx)
        desc = "Artist removed: \(removed.name) (\(removed.role)) — \(removed.wirelessChannels) wireless channel(s) freed"
    case 1:
        // Add a performer
        let extras = ["Special Guest", "Opening Act", "Added Artist", "Last-Minute Addition"]
        let types = ["HH", "BP", "headset"]
        let wType = rfPick(types)
        let newPerf = RFPerformerEntry(
            name: rfPick(extras),
            role: "Special Guest",
            location: "Center Stage",
            wirelessChannels: 1,
            wirelessType: wType,
            iemChannels: rfRand(0, 1),
            notes: "Added for Rehearsal \(iteration + 1)"
        )
        updated.performers.append(newPerf)
        desc = "Artist added: \(newPerf.name) — 1 \(wType) wireless required"
    default:
        // Swap wireless type for a performer
        if let idx = updated.performers.indices.first(where: { updated.performers[$0].wirelessChannels > 0 }) {
            let old = updated.performers[idx].wirelessType
            let new = old == "HH" ? "BP" : "HH"
            updated.performers[idx].wirelessType = new
            desc = "\(updated.performers[idx].name) changed from \(old) to \(new) wireless"
        } else {
            desc = "No changes this rehearsal"
        }
    }

    updated.changeLog.append("Rehearsal \(iteration + 1): \(desc)")
    return (updated, desc)
}

func rfPickN<T>(_ arr: [T], _ n: Int) -> [T] {
    var copy = arr; var out = [T]()
    for _ in 0..<min(n, copy.count) {
        let i = Int.random(in: 0..<copy.count)
        out.append(copy.remove(at: i))
    }
    return out
}
func rfRand(_ lo: Int, _ hi: Int) -> Int { Int.random(in: lo...hi) }


#if DEBUG
import SwiftUI

// MARK: - Preview Helpers

private struct RFSectionHeader: View {
    let title: String
    let count: Int

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text("\(count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private struct RFVenueCard: View {
    let venue: RFVenue

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(venue.name)
                        .font(.headline)

                    Text("\(venue.type) • \(venue.city)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(venue.rfEnv.rawValue)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(envColor.opacity(0.15))
                    .foregroundStyle(envColor)
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                Label("Cap. \(venue.capacity)", systemImage: "person.3")
                Label(venue.region, systemImage: "globe")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(venue.notes)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 430, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        )
    }

    private var envColor: Color {
        switch venue.rfEnv {
        case .low: .green
        case .moderate: .yellow
        case .busy: .orange
        case .veryBusy: .red
        }
    }
}

private struct RFWirelessSystemCard: View {
    let system: RFWirelessSystem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(system.system)
                        .font(.headline)

                    Text(system.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(system.key)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Frequency Bands")
                    .font(.subheadline.weight(.semibold))

                ForEach(Array(system.freqBands.keys.sorted()), id: \.self) { region in
                    let bands = system.freqBands[region] ?? []
                    Text("\(region): " + bands.map { "\($0.band) (\($0.range))" }.joined(separator: ", "))
                        .font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Receivers")
                    .font(.subheadline.weight(.semibold))
                ForEach(Array(system.receivers.enumerated()), id: \.offset) { _, rx in
                    Text("• \(rx.name) — \(rx.channels) ch")
                        .font(.caption)
                }
            }

            if !system.handhelds.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Handhelds")
                        .font(.subheadline.weight(.semibold))
                    ForEach(Array(system.handhelds.enumerated()), id: \.offset) { _, item in
                        Text("• \(item.name)")
                            .font(.caption)
                    }
                }
            }

            if !system.bodypacks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bodypacks")
                        .font(.subheadline.weight(.semibold))
                    ForEach(Array(system.bodypacks.enumerated()), id: \.offset) { _, item in
                        Text("• \(item.name)")
                            .font(.caption)
                    }
                }
            }

            if let iemTx = system.iemTx, !iemTx.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("IEM Transmitters")
                        .font(.subheadline.weight(.semibold))
                    ForEach(Array(iemTx.enumerated()), id: \.offset) { _, item in
                        Text("• \(item.name)")
                            .font(.caption)
                    }
                }
            }

            if let iemRx = system.iemRx, !iemRx.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("IEM Receivers")
                        .font(.subheadline.weight(.semibold))
                    ForEach(Array(iemRx.enumerated()), id: \.offset) { _, item in
                        Text("• \(item.name)")
                            .font(.caption)
                    }
                }
            }

            Text("Coordination: \(system.coord)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 460, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct RFListCard: View {
    let title: String
    let items: [RFListItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RFSectionHeader(title: title, count: items.count)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack {
                    Text(item.name)
                        .font(.caption)
                    Spacer()
                    Text(item.cat)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 420, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct RFDataSummaryView: View {
    private var venueCountsByEnv: [(RFEnvironment, Int)] {
        RFEnvironment.allCases.map { env in
            (env, rfVenues.filter { $0.rfEnv == env }.count)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("RF Planner Data Summary")
                .font(.headline)

            Text("Venues: \(rfVenues.count)")
            Text("Wireless Systems: \(rfWirelessSystems.count)")
            Text("Antennas: \(rfAntennas.count)")
            Text("Distros: \(rfDistros.count)")
            Text("Accessories: \(rfAccessories.count)")
                .foregroundStyle(.secondary)

            Divider()

            Text("Venue RF Environment Counts")
                .font(.subheadline.weight(.semibold))

            ForEach(venueCountsByEnv, id: \.0) { env, count in
                HStack {
                    Circle()
                        .fill(color(for: env))
                        .frame(width: 12, height: 12)

                    Text(env.rawValue)
                    Spacer()
                    Text("\(count)")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .padding()
        .frame(width: 280, alignment: .leading)
    }

    private func color(for env: RFEnvironment) -> Color {
        switch env {
        case .low: .green
        case .moderate: .yellow
        case .busy: .orange
        case .veryBusy: .red
        }
    }
}

// MARK: - Previews

#Preview("RF Summary") {
    RFDataSummaryView()
}

#Preview("Venues") {
    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            RFSectionHeader(title: "Venues", count: rfVenues.count)
            ForEach(Array(rfVenues.prefix(4).enumerated()), id: \.offset) { _, venue in
                RFVenueCard(venue: venue)
            }
        }
        .padding()
    }
    .frame(width: 480, height: 760)
}

#Preview("Wireless Systems") {
    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            RFSectionHeader(title: "Wireless Systems", count: rfWirelessSystems.count)
            ForEach(Array(rfWirelessSystems.prefix(3).enumerated()), id: \.offset) { _, system in
                RFWirelessSystemCard(system: system)
            }
        }
        .padding()
    }
    .frame(width: 520, height: 760)
}

#Preview("RF Lists") {
    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            RFListCard(title: "Antennas", items: rfAntennas)
            RFListCard(title: "Distros", items: rfDistros)
            RFListCard(title: "Accessories", items: rfAccessories)
        }
        .padding()
    }
    .frame(width: 460, height: 760)
}

#Preview("RF Data Browser") {
    ScrollView {
        VStack(alignment: .leading, spacing: 18) {
            RFDataSummaryView()

            RFSectionHeader(title: "Featured Venue", count: 1)
            if let venue = rfVenues.first {
                RFVenueCard(venue: venue)
            }

            RFSectionHeader(title: "Featured Wireless System", count: 1)
            if let system = rfWirelessSystems.first {
                RFWirelessSystemCard(system: system)
            }

            RFListCard(title: "Antennas", items: Array(rfAntennas.prefix(4)))
            RFListCard(title: "Distros", items: Array(rfDistros.prefix(4)))
        }
        .padding()
    }
    .frame(width: 540, height: 860)
}
#endif
