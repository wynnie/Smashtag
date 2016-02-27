//
//  MentionItem.swift
//  Smashtag
//
//  Created by Vinod Ananth on 3/14/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import Foundation
import UIKit

public enum MentionItem {
    case media (MediaItem)
    case text (Tweet.IndexedKeyword)
}