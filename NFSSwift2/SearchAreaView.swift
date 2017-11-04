//
//  SearchAreaView.swift
//  NFSSwift
//
//  Created by 璨 杨 on 15/11/22.
//  Copyright © 2015年 Gibbs. All rights reserved.
//

import Cocoa
import AudioToolbox
import AVFoundation
import CoreAudio

class SearchAreaView: NSView, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet var mySearchResultView: NSTableView!
    @IBOutlet var mySearchBar: NSSearchField!
    @IBOutlet var removeSearchHistory: NSButton!
    @IBOutlet var addSearchHistory:NSButton!
    @IBOutlet var searchHistoryComboBox:NSComboBox!
    @IBOutlet var contentView: NSView!

    private var searchResultHistory = Dictionary<String, Array<Sound>>();
    private var searchResult = Array<Sound>();
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect);
        MyInit();
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder);
        MyInit();
    }
    
    func MyInit() {
        NSBundle.mainBundle().loadNibNamed("SearchAreaView", owner: self, topLevelObjects: nil);
        self.contentView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
        self.addSubview(self.contentView);
        
        searchHistoryComboBox.addItemWithObjectValue("默认");
        searchHistoryComboBox.selectItemAtIndex(0);
        
        searchResultHistory.updateValue(Array<Sound>(), forKey: "默认");
        
        mySearchResultView.setDataSource(self);
        mySearchResultView.setDelegate(self);
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        self.contentView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
    }
    
    @IBAction func addSearchHistoryButtonClicked(sender: NSButton) {
        if searchResultHistory[mySearchBar.stringValue] == nil {
            searchHistoryComboBox.addItemWithObjectValue(mySearchBar.stringValue);
            searchHistoryComboBox.selectItemWithObjectValue(mySearchBar.stringValue);
        }
        searchResultHistory.updateValue(searchResult, forKey: mySearchBar.stringValue);
    }
    
    
    @IBAction func removeSearchHistoryButtonClicked(sender: NSButton) {
        if searchHistoryComboBox.stringValue != "默认" {
            searchResultHistory.removeValueForKey(searchHistoryComboBox.stringValue);
            searchHistoryComboBox.removeItemWithObjectValue(searchHistoryComboBox.stringValue);
            searchHistoryComboBox.itemObjectValueAtIndex(0);
            mySearchBar.stringValue = "";
            searchResult = Array<Sound>();
            mySearchResultView.reloadData();
        }
    }
    
    @IBAction func SearchHistoryitemChanged(sender: NSComboBox) {
        if searchResultHistory[searchHistoryComboBox.stringValue] != nil {
            searchResult = searchResultHistory[searchHistoryComboBox.stringValue]!;
            mySearchResultView.reloadData();
        }
    }
    
    /// 搜索框按回车后执行的函数
    @IBAction func mySearchBarDidInput(sender: NSSearchField) {
        if mySearchBar.stringValue != "" {
            searchResult = DataHelper.SearchData(mySearchBar.stringValue.lowercaseString.componentsSeparatedByString(" "));
            mySearchResultView.reloadData();
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return searchResult.count;
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return searchResult[row].SoundInfo[tableColumn!.identifier];
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {

    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        ApplicationHelper.SetSelectedSound(searchResult[row]);
        PlayerHelper.InitPlayer();
        return true;
    }
}
