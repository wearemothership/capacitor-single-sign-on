export interface SingleSignOnPlugin {
    authenticate(
        options: {
            url: string;
            customScheme?: string;
            redirectUri?: string;
        }
    ): Promise<{ url: string }>;
}
