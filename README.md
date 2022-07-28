# Monitoring repositories

This basic app monitors releases and tags for GitHub repositories (add one using the form at the top). The data is updated once every few hours. Releases take precendence over tags unless the latest release is significantly older.

To avoid the rate limit, the environment needs to have a `PERSONAL_ACCESS_TOKEN` variable defined.

The repositories are sorted by the latest release date.

The index page shows only the new features snippet whenever possible; to see the full notes, use the link at the top of each entry.