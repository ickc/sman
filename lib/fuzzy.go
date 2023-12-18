package sman

import (
	"github.com/lithammer/fuzzysearch/fuzzy"
	"sort"
)

// topsFromRanks iterates through fuzzy.Ranks and returns results
// whith the best distance
func topsFromRanks(ranks fuzzy.Ranks) (matched []string) {
	if len(ranks) == 0 {
		return matched
	}
	sort.Sort(ranks)
	topDistance := ranks[0].Distance
	for _, r := range ranks {
		if r.Distance == topDistance {
			matched = append(matched, r.Target)
		} else {
			break
		}
	}
	return matched
}

//fSearchFileName fuzzy searches pattern within available files in a dir
func fSearchFileName(pattern string, dir string) (matched []string) {
	files := ymlFiles(dir)
	ranks := fuzzy.RankFind(pattern, files)
	return topsFromRanks(ranks)
}

// fSearchSnippet matches pattern to snippet name in SnippetSlice
// returnes SnippetSlice of best matched snippets.
func fSearchSnippet(snippets SnippetSlice, pattern string) (matched SnippetSlice) {
	topRank := -1
	for _, s := range snippets {
		r := fuzzy.RankMatch(pattern, s.Name)
		switch {
		case r == -1:
			continue
		case topRank == -1 || r < topRank:
			matched = SnippetSlice{s}
			topRank = r
		case r == topRank:
			matched = append(matched, s)
		}
	}
	return matched
}
