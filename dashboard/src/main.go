package main

import (
	"time"

	"github.com/capistrano/stats/redis"
	"github.com/capistrano/stats/rubygems"

	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

var t time.Time = time.Now().UTC()
var periods map[string]string = map[string]string{
	fmt.Sprintf("%02d-%02d-%d", t.Day(), t.Month(), t.Year()):   "Today",
	fmt.Sprintf("%02d-%02d-%d", t.Day()-1, t.Month(), t.Year()): "Yesterday",
	fmt.Sprintf("%02d-%d", t.Month(), t.Year()):                 "This Month",
	fmt.Sprintf("%02d-%d", t.Month()-1, t.Year()):               "Last Month",
	fmt.Sprintf("%d", t.Year()):                                 "This Year",
	fmt.Sprintf("%d", t.Year()-1):                               "Last Year",
}

var printOrder []string = []string{
	"Today",
	"Yesterday",
	"This Month",
	"Last Month",
	"This Year",
	"Last Year",
}

type DisplayPeriod struct {
	Title                       string
	Cardinality                 int64
	CorrectedCardinality        int64
	ProjectCardinality          int64
	CorrectedProjectCardinality int64
}

func main() {
	var pubVersions []rubygems.Version
	resp, err := http.Get("https://rubygems.org/api/v1/versions/capistrano.json")
	if err != nil {
		log.Fatal("Error retrieving document from Rubygems API")
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal("Error retrieving document from Rubygems API")
	}
	if err := json.Unmarshal(body, &pubVersions); err != nil {
		log.Fatal("Couldn't unmarshal response from rubygems.org")
	}

	rgds := rubygems.NewDownloadSummary(pubVersions)
	log.Println(rgds)

	ra, err := redis.NewAdapter(":6379")
	if err != nil {
		log.Fatal("Couldn't connect to redis")
	}
	var displayPeriods []DisplayPeriod
	for _, title := range printOrder {
		var setKey string
		for sK, t := range periods {
			if t == title {
				setKey = sK
			}
		}
		card, err := ra.SetCardinality(setKey)
		if err != nil {
			log.Fatal("Couldn't query redis")
		}
		pCard, err := ra.SetCardinality(setKey + "|anon_project_hash")
		if err != nil {
			log.Fatal("Couldn't query redis")
		}
		displayPeriods = append(displayPeriods, DisplayPeriod{
			Title:                       title,
			Cardinality:                 card,
			ProjectCardinality:          pCard,
			CorrectedCardinality:        rgds.CorrectMetricCount(card),
			CorrectedProjectCardinality: rgds.CorrectMetricCount(pCard),
		})
	}

	// Deploys
	log.Printf("==> Projects")
	for _, dp := range displayPeriods {
		log.Printf("%6d\t(%6d)\t%s", dp.ProjectCardinality, dp.CorrectedProjectCardinality, dp.Title)
	}
	log.Printf("==> Deploys")
	for _, dp := range displayPeriods {
		log.Printf("%6d\t(%6d)\t%s", dp.Cardinality, dp.CorrectedCardinality, dp.Title)
	}
}
