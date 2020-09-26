module source.scores;

import source.app;

struct ScoresDetails {
    string name;
    int score;
    int diamonds;
    int lives;
    string date;
    string time;
    string comment = "(no comment)";

    // Joel Christensen,3000,30,26.09.2020,4:00pm
    string toData() {
        return text(name,"|",score,"|",diamonds,"|",lives,"|",date,"|",time,"|",comment);
    }

    string toString() const {
        return text("Name: ", name, ", Score: ", score, ", Diamonds: ", diamonds, ", Lives: ", lives,
                    ", Date: ", date, ", Time: ", time); //, ", Comment: ", comment);
    }
}

struct ScoresMan {
    ScoresDetails[] cards;

    void load(in string scoresFile = "halloffame.txt") {
        cards.length = 0;
        import std.file, std.string;
        auto wholeData = readText(scoresFile).stripRight;
        //Joel|4308|23|0|26.sep.2020|[ 1:07:10pm]|(no comment)
        foreach(line; wholeData.split("\n")) {
            auto data = line.split("|");
            assert(data.length == 7, "error in " ~ scoresFile ~ " data");
            add(ScoresDetails(data[0],data[1].to!int,data[2].to!int,data[3].to!int,data[4],data[5],data[6]));
        }
    }

    void doSort() {
        import std.algorithm, std.array;
        cards = cards.sort!((a,b) => a.score > b.score).array;
    }

    void save(in string scoresFile = "halloffame.txt") {
        doSort;
        import std.file;
        auto f = File(scoresFile, "w");
        foreach(card; cards)
            f.writeln(card.toData);
    }

    void add(in ScoresDetails scoreCard) {
        with(scoreCard)
            cards ~= ScoresDetails(name,score,diamonds,lives,date,time,comment);
    }
}
