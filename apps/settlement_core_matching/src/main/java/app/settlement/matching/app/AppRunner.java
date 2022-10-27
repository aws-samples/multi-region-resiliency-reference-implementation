// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.matching.app;

import app.settlement.matching.utils.RegionStateManager;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import scala.App;

@Component
public class AppRunner  implements CommandLineRunner {

    RegionStateManager regionStateManager;
    public AppRunner(RegionStateManager state)
    {
        this.regionStateManager = state;
    }

    @Override
    public void run(String... args) throws Exception {
      this.regionStateManager.checkRegionState();
    }
}
