//#not used
module source.scores;

import source.app;

struct ScoresDetails {
    string name;
    string levelsPlayed;
    int score;
    int diamonds;
    int lives;
    string date;
    string time;
    string comment = "(no comment)";

    // Joel Christensen,3000,30,26.09.2020,4:00pm
    string toData() {
        return text(name,"|",levelsPlayed,"|",score,"|",diamonds,"|",lives,"|",date,"|",time,"|",comment);
    }

    //#not used
    string toString() const {
        return text("Name: ", name, "Levels: ", levelsPlayed, ", Score: ", score, ", Diamonds: ", diamonds, ", Lives: ", lives,
                    ", Date: ", date, ", Time: ", time); //, ", Comment: ", comment);
    }
}

struct ScoresMan {
    ScoresDetails[] cards;

    void load(in string scoresFile = "halloffame.txt") {
        cards.length = 0;
        import std.file, std.string;
        import std.path : buildPath;
        auto wholeData = readText(buildPath(g_gameFolder, scoresFile)).stripRight;
        //Old: Joel|4308|23|0|26.sep.2020|[ 1:07:10pm]|(no comment)
        //Joel|1-3|4308|23|0|26.sep.2020|[ 1:07:10pm]|(no comment)
        foreach(line; wholeData.split("\n")) {
            auto data = line.split("|");
            assert(data.length == 8, "error in " ~ scoresFile ~ " data");
            add(ScoresDetails(data[0],data[1],data[2].to!int,data[3].to!int,data[4].to!int,data[5],data[6],data[7]));
        }
    }

    void doSort() {
        import std.algorithm, std.array;
        cards = cards.sort!((a,b) => a.score > b.score).array;
    }

    void save(in string scoresFile = "halloffame.txt") {
        doSort;
        import std.file;
        import std.path : buildPath;
        auto f = File(buildPath(g_gameFolder, scoresFile), "w");
        foreach(card; cards)
            f.writeln(card.toData);
    }

    void add(in ScoresDetails scoreCard) {
        with(scoreCard)
            cards ~= ScoresDetails(name,levelsPlayed,score,diamonds,lives,date,time,comment);
    }
}
