package be.socrates.tempeldesschreckens.resource;

public class Identification {
    private String secretToken;

    public Identification(final String secretToken) {
        this.secretToken = secretToken;
    }

    public String getSecretToken() {
        return secretToken;
    }
}
