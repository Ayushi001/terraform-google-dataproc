// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package multiple_buckets

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func TestSimpleExample(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)

	example.DefineVerify(func(assert *assert.Assertions) {
		example.DefaultVerify(assert)

		projectID := example.GetStringOutput("project_id")
		services := gcloud.Run(t, "services list", gcloud.WithCommonArgs([]string{"--project", projectID, "--format", "json"})).Array()

		match := utils.GetFirstMatchResult(t, services, "config.name", "dataproc.googleapis.com")
		assert.Equal("ENABLED", match.Get("state").String(), "Dataproc API service should be enabled")

		// verify module outputs are populated
		clusterName := example.GetStringOutput("cluster_name")
		clusterID := example.GetStringOutput("cluster_id")
		clusterRegion := example.GetStringOutput("cluster_region")
		clusterProject := example.GetStringOutput("cluster_project")

		assert.NotEmpty(clusterName, "cluster_name output should not be empty")
		assert.NotEmpty(clusterID, "cluster_id output should not be empty")
		assert.Equal(projectID, clusterProject, "cluster_project output should match the project id")
		assert.NotEmpty(clusterRegion, "cluster_region output should not be empty")
	})
	example.Test()
}
