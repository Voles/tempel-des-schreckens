package be.socrates.tempeldesschreckens.resource;

public class OpenInput {
    private String secretToken; //of source player
    private int targetPlayerId;

    public OpenInput(final String secretToken, final int targetPlayerId) {
        this.secretToken = secretToken;
        this.targetPlayerId = targetPlayerId;
    }

    public String getSecretToken() {
        return secretToken;
    }

    public int getTargetPlayerId() {
        return targetPlayerId;
    }
}
