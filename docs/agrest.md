---
title: Unofficial NHL API Docs - Agrest Protocol Query
---

# Unofficial NHL API Docs

## Agrest Protocol Query Parameters

The following NHL APIs both use Apache Cayenne which allows submissions of complex queries via the Agrest Protocol.

Below are demonstrates of how to use each query parameter. All links are example GET requests demonstrating the parameter usage.

### `cayenneExp`

Accepts an expression that evaluates to true/false.

Parses the operators:

* `and`: AND conjunction
* `or`: OR conjunction
* `not` | `!`: NOT conjunction/operator
* `==` | `=`: EQ operator
* `!=` | `<>`: NOTEQ operator
* `<`: LESSTHAN operator
* `<=`: LESSTHANEQ operator
* `>`: MORETHAN operator
* `>=`: MORETHANEQ operator
* `in`: IN operator. RHS must be a comma separated list of literals in round brackets. returns true for any attributes matching any values in provided list
   * e.g. [`sweaterNumber in (15, 19)`](https://api.nhle.com/stats/rest/en/players?cayenneExp=sweaterNumber%20in%20(16,19))
   * e.g. [`skaterFullName in ("Jack Hughes", "Elias Pettersson")`](https://api.nhle.com/stats/rest/en/skater/summary?&cayenneExp=skaterFullName%20in%20(%22Jack%20Hughes%22,%20%22Elias%20Pettersson%22))
* `between`: BETWEEN operator. RHS must be of the form `<val0> and <val2>`, is equivalent to matching all `x` where `<val1> < x < <val2>`
   * e.g. [`points between 19 and 30`](https://api.nhle.com/stats/rest/en/skater/summary?&cayenneExp=points%20between%2020%20and%2030)
* `.`: Get child object from current (root) object
* `like`: LIKE operator. Matches **patterns**
* `likeIgnoreCase`: LIKE operator that is case insensitive

A very basic form of pattern matching is provided for usage with `like` and `likeIgnoreCase`. seems to allow any character as is, except the `%` character which acts as a multicharacter wildcard (not unlike `.*` in a regex expression).

For example to match all players with the first/last name Connor/Conor in the league: [`firstName likeIgnoreCase "%Con%or%"`](https://api.nhle.com/stats/rest/en/skater/summary?&cayenneExp=skaterFullName%20likeIgnoreCase%20%22%Con%or%%22)

The API also provides the methods:

* `year(date: Date) => number`: gets year from date.
   * `year(firstSeason.endDate) < 1979`
      * [Example](https://api.nhle.com/stats/rest/en/franchise?sort=firstSeason.startDate&dir=DESC&include=firstSeason&cayenneExp=year(firstSeason.endDate)%20%3C%201980)
* `month(date: Date) => number`: gets year from date
   * `month(lastSeason.endDate) < 3`
* `week(date: Date) => number`: gets week from date
   * `week(lastSeason.endDate) < 11`
* `length(string: String) => number`: gets length of strings
   * `length(fullName) > 19`
* `locate(string: String, substring: String) => number`: gets first index of substring. Seems to be 0 indexed.
   * `locate(lastName, 'ov') > 0`
   * `locate('Zachary', firstName) > -1`
      * [Example](https://api.nhle.com/stats/rest/en/players?cayenneExp=locate(%27Zachary%27,%20firstName)%20%3E%200)
* `abs(number: Number) => number`: gets absolute value
* `sqrt(number: Number) => number`: gets square root
* `mod(dividend: Number, divisor: Number) => number`: get remainder after dividing

### `start`/`limit`

Start from record number `<start>` and limit to `<limit>` records returned in `?start=<start>&limit=<limit>`.

### `sort`/`dir`

* `sort=seasonId`: (ascending by default)
   * [Example](https://records.nhl.com/site/api/franchise-season-results?cayenneExp=triCode=%27WSH%27&sort=seasonId)
* `sort=seasonId&dir=DESC`: (explicitly descending)
   * [Example](https://records.nhl.com/site/api/franchise-season-results?cayenneExp=triCode='WSH'&sort=seasonId&dir=DESC)
* `sort=seasonId&dir=DESC`: (explicitly descending)
   * [Example](https://records.nhl.com/site/api/franchise-season-results?cayenneExp=triCode=%27WSH%27&sort=seasonId&dir=DESC)
* `sort={"property":"goals","direction":"DESC"}`: for one sorting key
* `sort=[{"property":"goals","direction":"DESC"},{"property":"gamesPlayed","direction":"ASC"}]`: for multiple sorting keys
   * [Example from actual records site](https://records.nhl.com/site/api/skater-career-scoring-regular-season?limit=9&cayenneExp=goals%20%3E=%20200%20and%20franchiseId!=null&sort=[{%22property%22:%22goals%22,%22direction%22:%22DESC%22},{%22property%22:%22gamesPlayed%22,%22direction%22:%22ASC%22},{%22property%22:%22lastName%22,%22direction%22:%22ASC%22}])

### `mapBy`

the response of a successful Agrest request is always in the form of

    {
        data: [...],
        total: <count>
    }

`data` is always a list of the returned documents, but you can convert this to a map with the key provided in mapBy, that maps to a list of the documents matching the key provided.

Compare the [first](https://records.nhl.com/site/api/nhl/record-detail?cayenneExp=recordCategory=%222%22&include=recordToFranchise&sort=[{%22property%22:%22recordType.sequence%22},{%22property%22:%22recordToFranchise.sequence%22}]) request

    {
        data: [{
            id: 13,
            description: "Most Seasons Played, Career",
            descriptionKey: "most-seasons",
        }, ...  ],
        total: 199
    }

to the [second](https://records.nhl.com/site/api/nhl/record-detail?cayenneExp=recordCategory=%222%22&include=recordToFranchise&sort=[{%22property%22:%22recordType.sequence%22},{%22property%22:%22recordToFranchise.sequence%22}]&mapBy=recordType.description):

    {
        data: {
            'Seasons and Games': [
                {
                    id: 13,
                    description: "Most Seasons Played, Career",
                    descriptionKey: "most-seasons",
                    recordToFranchise: [...]
                },
                {
                    id: 14,
                    description: "Most Games Played, Career",
                    descriptionKey: "most-games-played",
                    recordToFranchise: [...]
                }, ...
            ], ...
        },
        total: 199
    }

### `include`/`exclude`

To simply display only a selected few fields: e.g. [`&include=["assists","evGoals","lastName"]` or `&include=assists&include=evGoals&include=lastName`](https://api.nhle.com/stats/rest/en/skater/summary?limit=11&start=1&sort=points&include=[%22assists%22,%22evGoals%22,%22lastName%22]&dir=DESC&cayenneExp=seasonId=20202021)

Or to simply hide those fields: e.g. [`&exclude=["assists","evGoals","lastName"]` or `&exclude=assists&exclude=evGoals&exclude=lastName`](https://api.nhle.com/stats/rest/en/skater/summary?limit=11&start=1&sort=points&exclude=[%22assists%22,%22evGoals%22,%22lastName%22]&dir=DESC&cayenneExp=seasonId=20202021)

The cool thing is that you can include related fields that would otherwise not be returned in the basic query: [`&include=recordCategory in this query` in this query](https://records.nhl.com/site/api/nhl/record-detail?cayenneExp=recordCategory=%222%22&include=recordCategory&include=recordType&include=recordToFranchise&exclude=recordType.descriptionKey&sort=[{%22property%22:%22recordToFranchise.sequence%22}])

Nested fields in these related fields can be included/excluded as well [`&exclude=recordType.descriptionKey`](https://records.nhl.com/site/api/nhl/record-detail?cayenneExp=recordCategory="2"&include=recordCategory&include=recordType&include=recordToFranchise&exclude=recordType.descriptionKey&sort=[{"property":"recordToFranchise.sequence"}])

JSON notation allows for recursively applying operations to children objects in this example with [`&include={"path":"recordToFranchise", "mapBy": "id"}`](https://records.nhl.com/site/api/nhl/record-detail?cayenneExp=recordCategory=%222%22&include=recordCategory&include=recordType&include={%22path%22:%22recordToFranchise%22,%22mapBy%22:%22id%22}&sort=[{%22property%22:%22recordToFranchise.sequence%22}])

More examples of how the include/exclude query parameters can be structured can be found [here](https://vyarmolovich.github.io/agrest/docs/protocol.html#shaping-collection-with-include-exclude). The biggest hurdle is that there isn't any public info on the relationship model, so we won't know the full scope of items we can include for any request. Though with some trial and error it's possible it can be figured out.

### `isAggregate`/`isGame`

Without either flag: the query [https://api.nhle.com/stats/rest/en/team/summary?&sort=\[%6B%22property%22:%22pointPct%22,%22direction%22:%22DESC%22%7D\]](https://api.nhle.com/stats/rest/en/team/summary?&sort=[%7B%22property%22:%22pointPct%22,%22direction%22:%22DESC%22%7D]) returns the report data per season from api.nhle.com/stats/rest.

With `isAggregate`, you get the aggregated data across **all seasons**: [link](https://api.nhle.com/stats/rest/en/team/summary?&isAggregate=true&sort=[{%22property%22:%22pointPct%22,%22direction%22:%22DESC%22}])

With `isGame`, you get the data from **each game**: [link](https://api.nhle.com/stats/rest/en/team/summary?&isGame=true&sort=[{%22property%22:%22pointPct%22,%22direction%22:%22DESC%22}])



## NHL Records: `https://records.nhl.com/site/api/`

All endpoints described in this section are relative to the following base URL:
`https://records.nhl.com/site/api/`.

### GET Content modules on page

*endpoint*: https://records.nhl.com/site/api/nhl/content/module/{page-name}
*description*: Returns documents of site content layout information as modules. Modules act as content placeholders.

*parameters*:
`{module-type}`: One of the following

- Home
- Footer
- RecordsIndividual
- RecordsGoalie
- NHLAllTimeStandings
- 500GoalCareer
- 1000PointCareer
- 50GoalSeason
- AwardsIndex
- AllStarGames
- OutdoorGames
- GamesOutsideNorthAmerica
- ThreeStarsSelection
- AllStarSelection
- DraftPicks
- DraftLotteryResults
- ExpansionDraftPicks
- NHLHistory
- NHLHistoryRules
- Referees
- NHLAttendance
- NHLOrganization
- NHLOffices
- NHLPAOffices

*Available `include`s:*
- `published`: Published data in the placeholder's position

*Example document returned*:

```json
{
  "id": 102,
  "cssPath": null,
  "description": "Second module in side bar",
  "divClass": null,
  "divId": null,
  "optional": true,
  "sequence": 5,
  "siteVersion": {
    "vhost": "grb",
    "lang": "en",
    "version": "1",
    "id": "grb:en:1"
  },
  "templateKey": "Home"
}
```

*Request*:

```
curl -X GET "https://records.nhl.com/site/api/nhl/content/module/Home?mapBy=sequence&include=published"
```

### WIP



## NHL Stats: `https://api.nhle.com/stats/rest/`

All endpoints described in this section are relative to the following base URL:
`https://api.nhle.com/stats/rest/`.

### Config

The JSON returned at [https://api.nhle.com/stats/rest/en/config] describes the report types for 
goalies, skaters and teams, and columns that aggregates can be computed across. It also describes
individual columns, not sure what that is supposed to indicate though. See [Config Information](#config-information) for details.

#### Overview (and keywords)

**Report**: A group of *attributes* per game or per season.

**Attributes**: Information entry within the report.

**Skater**: Forward or defenseman. reports and attributes described by `playerReportData` from config.

**Goalie**: Goaltender. Reports and attributes described by `goalieReportData` from config.

**Player**: A subset of bio information for both skaters and goalies.

**Team**: Reports and attributes described by `teamReportData` from config.

**Franchise**: A subset of information per team.

### Common Parameters

`lang`: Language. Use `en` unless otherwise necessary

### Players

**Endpoint**: `/{lang}/players`

**Query**
```sh
curl -X GET "https://api.nhle.com/stats/rest/en/players"

curl -X GET "https://api.nhle.com/stats/rest/en/players?cayenneExp=sweaterNumber=99"
```

### Skaters

#### GET Skater Reports

**Endpoint**: `/{lang}/skater/{report}`

*parameters*:

`report`:

- summary
- realtime
- penalties
- shootout
- bios
- shottype
- faceoffpercentages
- percentages
- scoringRates
- penaltyShots
- puckPossessions
- timeonice
- summaryshooting
- powerplay
- goalsForAgainst
- scoringpergame
- penaltykill
- faceoffwins

<details>

<summary>`summary`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/summary?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`realtime`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/realtime?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`penalties`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/penalties?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 15,
      "blockedShotsPer60": 0.53,
      "emptyNetAssists": 2,
      "emptyNetGoals": 4,
      "emptyNetPoints": 6,
      "firstGoals": 7,
      "gamesPlayed": 86,
      "giveaways": 57,
      "giveawaysPer60": 2.03,
      "hits": 26,
      "hitsPer60": 0.92,
      "lastName": "Panarin",
      "missedShotCrossbar": 0,
      "missedShotGoalpost": 8,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 71,
      "missedShots": 93,
      "otGoals": 1,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20162017,
      "shootsCatches": "R",
      "shotAttemptsBlocked": 101,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 62,
      "takeawaysPer60": 2.21,
      "teamAbbrevs": "CHI",
      "timeOnIcePerGame": 1172.15
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`shootout`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/shootout?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`bios`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/bios?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`shottype`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/shottype?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`faceoffpercentages`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/faceoffpercentages?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`percentages`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/percentages?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 15,
      "blockedShotsPer60": 0.53,
      "emptyNetAssists": 2,
      "emptyNetGoals": 4,
      "emptyNetPoints": 6,
      "firstGoals": 7,
      "gamesPlayed": 86,
      "giveaways": 57,
      "giveawaysPer60": 2.03,
      "hits": 26,
      "hitsPer60": 0.92,
      "lastName": "Panarin",
      "missedShotCrossbar": 0,
      "missedShotGoalpost": 8,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 71,
      "missedShots": 93,
      "otGoals": 1,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20162017,
      "shootsCatches": "R",
      "shotAttemptsBlocked": 101,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 62,
      "takeawaysPer60": 2.21,
      "teamAbbrevs": "CHI",
      "timeOnIcePerGame": 1172.15
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`scoringRates`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/scoringRates?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 15,
      "blockedShotsPer60": 0.53,
      "emptyNetAssists": 2,
      "emptyNetGoals": 4,
      "emptyNetPoints": 6,
      "firstGoals": 7,
      "gamesPlayed": 86,
      "giveaways": 57,
      "giveawaysPer60": 2.03,
      "hits": 26,
      "hitsPer60": 0.92,
      "lastName": "Panarin",
      "missedShotCrossbar": 0,
      "missedShotGoalpost": 8,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 71,
      "missedShots": 93,
      "otGoals": 1,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20162017,
      "shootsCatches": "R",
      "shotAttemptsBlocked": 101,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 62,
      "takeawaysPer60": 2.21,
      "teamAbbrevs": "CHI",
      "timeOnIcePerGame": 1172.15
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`penaltyShots`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/penaltyShots?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`puckPossessions`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/puckPossessions?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`timeonice`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/timeonice?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`summaryshooting`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/summaryshooting?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`powerplay`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/powerplay?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`goalsForAgainst`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/goalsForAgainst?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`scoringpergame`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/scoringpergame?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`penaltykill`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/penaltykill?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>
        

<details>

<summary>`faceoffwins`</summary>

*Request*:
```sh
curl +X GET "https://api.nhle.com/stats/rest/en/skater/faceoffwins?limit=1&cayenneExp=skaterFullName='Artemi Panarin'"
```

*Response*:
```json
{
  "data": [
    {
      "blockedShots": 19,
      "blockedShotsPer60": 0.63,
      "emptyNetAssists": 3,
      "emptyNetGoals": 2,
      "emptyNetPoints": 5,
      "firstGoals": 0,
      "gamesPlayed": 89,
      "giveaways": 64,
      "giveawaysPer60": 2.14,
      "hits": 17,
      "hitsPer60": 0.57,
      "lastName": "Panarin",
      "missedShotCrossbar": 5,
      "missedShotGoalpost": 4,
      "missedShotOverNet": 14,
      "missedShotShort": null,
      "missedShotWideOfNet": 50,
      "missedShots": 73,
      "otGoals": 4,
      "playerId": 8478550,
      "positionCode": "L",
      "seasonId": 20182019,
      "shootsCatches": "R",
      "shotAttemptsBlocked": null,
      "skaterFullName": "Artemi Panarin",
      "takeaways": 42,
      "takeawaysPer60": 1.41,
      "teamAbbrevs": "CBJ",
      "timeOnIcePerGame": 1204.08
    }
  ],
  "total": 9
}
```
</details>

#### GET Skater Leaders

**Endpoint**: `/{lang}/leaders/skaters/{attribute}`

#### GET Skater Milestones

**Endpoint**: `/{lang}/milestones/skaters`

### Goalies

#### GET Goalie Reports

**Endpoint**: `/{lang}/goalie/{report}`

`report`:

- summary
- shootout
- advanced
- bios
- startedVsRelieved
- savesByStrength
- daysrest
- penaltyShots

</details>

#### GET Goalie Leaders

**Endpoint**: `/{lang}/leaders/goalies/{attribute}`

#### GET Goalie Milestones

**Endpoint**: `/{lang}/milestones/goalies`

### Teams

#### GET Team Basic Info

**Endpoint**: `/{lang}/team`

`report`:

- summary
- goalsagainstbystrength
- realtime
- penaltykilltime
- goalgames
- powerplaytime
- penalties
- shootout
- shottype
- faceoffpercentages
- percentages
- scoretrailfirst
- daysbetweengames
- outshootoutshotby
- leadingtrailing
- goalsbyperiod
- summaryshooting
- powerplay
- penaltykill
- faceoffwins
- goalsforbystrength

#### GET Franchise Info

**Endpoint**: `/{lang}/franchise`

#### GET Team Reports

**Endpoint**: `/{lang}/team/{report}`

### Seasons

#### GET Season Info

**Endpoint**: `/{lang}/season`

#### GET Current season and game type

**Endpoint**: `/{lang}/componentSeason`

### Content

**Endpoint**: `/en/content/module/{module-type}`

- StatsHomePage
