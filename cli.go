package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "pigeon",
	Short: "Pigeon is a peer-to-peer database for offline systems",
	Long: `Pigeon is an off-grid, serverless, peer-to-peer
	database for building software that works on poor internet
	connections, or entirely offline.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("It works!")
	},
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "This is the short description of version",
	Long:  `This one is longer.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Pigeon CLI Client (Golang), version %s\n", Version)
	},
}

// BootstrapCLI wires up all the relevant commands.
func BootstrapCLI() {
	rootCmd.AddCommand(versionCmd)
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
