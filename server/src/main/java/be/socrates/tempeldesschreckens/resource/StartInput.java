package be.socrates.tempeldesschreckens.resource;

public class StartInput {
    private int playerCount;

    public StartInput(final int playerCount) {
        this.playerCount = playerCount;
    }

    public int getPlayerCount() {
        return playerCount;
    }
}
