package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// CLI: `pigeon`
var rootCmd = &cobra.Command{
	Use:   "pigeon",
	Short: "Pigeon is a peer-to-peer database for offline systems.",
	Long: `Pigeon is an off-grid, serverless, peer-to-peer
	database for building software that works on poor internet
	connections, or entirely offline.`,
	Run: func(cmd *cobra.Command, args []string) {
	},
}

// CLI: `pigeon version`
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the software version.",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Pigeon CLI Client (Golang), version %s\n", Version)
	},
}

// CLI: `pigeon identity`
var identityRootCmd = &cobra.Command{
	Use:   "identity",
	Short: "Identity related commands",
	Run: func(cmd *cobra.Command, args []string) {
	},
}

// CLI: `pigeon identity create`
var identityCreateCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a new identity.",
	Long:  `Creates a new identity.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(createOrShowIdentity())
	},
}

// CLI: `pigeon identity show`
var identityShowCmd = &cobra.Command{
	Use:   "identity",
	Short: "Show current user identity.",
	Long: `Prints the current Pigeon identity to screen. Prints 'NONE' if
	not found.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(showIdentity())
	},
}

// CLI: `pigeon peer`
var peerRootCmd = &cobra.Command{
	Use:     "peer(s)",
	Short:   "Peer related commands",
	Aliases: []string{"peer", "peers"},
	Run: func(cmd *cobra.Command, args []string) {
	},
}

var peerBlockCmd = &cobra.Command{
	Use:   "block",
	Short: "Block a peer from your local node.",
	Run: func(cmd *cobra.Command, args []string) {
		mhash := args[0]
		fmt.Printf("TODO: Validate this input string %s\n", mhash)
	},
}

// BootstrapCLI wires up all the relevant commands.
func BootstrapCLI() {
	rootCmd.AddCommand(versionCmd)

	rootCmd.AddCommand(identityRootCmd)
	identityRootCmd.AddCommand(identityShowCmd)
	identityRootCmd.AddCommand(identityCreateCmd)

	rootCmd.AddCommand(peerRootCmd)
	peerRootCmd.AddCommand(peerBlockCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
