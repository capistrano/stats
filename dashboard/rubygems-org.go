package main

import "encoding/json"

type RubyGemsVersion struct {
	DownloadsCount int    `json:"downloads_count"`
	Version        string `json:"number"`
}

func (rgv *RubyGemsVersion) HasStats() bool {

}

func (rgv *RubyGemsVersion) Is3x() bool {

}

func main() {
	var pubVersions []RubyGemsVersion
	if err := json.Unmarshal(body, &pubVersions) {

	}
}
