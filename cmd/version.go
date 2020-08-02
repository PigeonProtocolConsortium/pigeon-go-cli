package cmd

import (
	"fmt"
	"pigeon/pigeon"

	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Show the version of the Pigeon CLI tool.",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		result := fmt.Sprintf("Pigeon v%s", pigeon.Version)
		fmt.Println(result)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
