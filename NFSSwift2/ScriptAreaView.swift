//
//  ScriptAreaView.swift
//  NFSSwift
//
//  Created by 璨 杨 on 15/11/29.
//  Copyright © 2015年 Gibbs. All rights reserved.
//

import Cocoa
import AudioToolbox
import AVFoundation
import CoreAudio

class ScriptAreaView: NSView, NSOutlineViewDataSource, NSOutlineViewDelegate, NSWindowDelegate {

    var myNewWindow = NSWindow();
    var EditView = EditViewController();
    
    private var CustomLibrary = Library();
    
    @IBOutlet var LibrariesTree: NSOutlineView!
    @IBOutlet var contentView: NSView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect);
        MyInit();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        MyInit();
    }
    
    func MyInit() {
        NSBundle.mainBundle().loadNibNamed("ScriptAreaView", owner: self, topLevelObjects: nil);
        self.contentView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
        self.addSubview(self.contentView);
        
        CustomLibrary.LibraryName = "新剧本";
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        self.contentView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
    }
    
    @IBAction func ContextMenuClicked(sender: NSMenuItem) {
        myNewWindow = NSWindow(contentViewController: EditViewController());
        myNewWindow.delegate = self;
        myNewWindow.title = sender.title;
        EditView = myNewWindow.contentViewController as! EditViewController;
        switch (sender.title) {
        case "新建节点":
            if LibrariesTree.selectedRow == -1{
                break;
            }
            let item = LibrariesTree.itemAtRow(LibrariesTree.selectedRow);
            if item is Sound {
                break;
            }
            EditView.EditWindowInit("节点名称：", message: "新节点", editType: EditTypeEnum.CreateLeaf);
            myNewWindow.makeKeyAndOrderFront(nil)
            break;
        case "删除节点":
            if LibrariesTree.selectedRow == -1{
                break ;
            }
            let item = LibrariesTree.itemAtRow(LibrariesTree.selectedRow);
            if item is Sound {
                let sound = item as! Sound;
                var soundindex = 0;
                while sound.FatherLibrary.Sounds[soundindex] != sound{
                    soundindex++;
                }
                sound.FatherLibrary.Sounds.removeAtIndex(soundindex);
            }
            else if item is Library{
                let lib = item as! Library;
                if lib.FatherLibrary == nil{
                    CustomLibrary = Library();
                    CustomLibrary.LibraryName = "新剧本";
                }
                else{
                    var libindex = 0;
                    while lib.FatherLibrary?.Folders[libindex] != lib{
                        libindex++;
                    }
                    lib.FatherLibrary?.Folders.removeAtIndex(libindex);
                }
            }
            LibrariesTree.reloadData();
            break;
        case "重命名节点":
            if LibrariesTree.selectedRow == -1{
                break;
            }
            let item = LibrariesTree.itemAtRow(LibrariesTree.selectedRow);
            EditView.EditWindowInit("节点名称：", message: item is Library ? (item as! Library).LibraryName : (item as! Sound).SoundInfo[SoundInfoEnum.FileDisplayName.rawValue]! , editType: EditTypeEnum.RenameLeaf);
            myNewWindow.makeKeyAndOrderFront(nil)
            break;
        case "新建剧本":
            EditView.EditWindowInit("剧本名称：", message: "新剧本", editType: EditTypeEnum.CreateScript);
            myNewWindow.makeKeyAndOrderFront(nil)
            break;
        case "导出剧本":
            let savePanel = NSSavePanel();
            savePanel.message = "请选择剧本导出的位置";
            savePanel.nameFieldStringValue = CustomLibrary.LibraryName + ".script";
            if savePanel.runModal() == NSFileHandlingPanelOKButton {
                let root = NSXMLElement(name: "Library");
                root.addChild(NSXMLElement(name: "LibraryName", stringValue: CustomLibrary.LibraryName));
                let tree = NSXMLElement(name: "Tree");
                root.addChild(tree);
                LibraryHelper.CreateScriptFileFromLibrary(CustomLibrary, root: tree);
                let xmlDoc = NSXMLDocument(rootElement: root);
                let alertWindow = NSAlert();
                alertWindow.messageText = "Hello";
                alertWindow.informativeText = xmlDoc.XMLData.writeToFile(savePanel.URL!.path!, atomically: false) ? "已保存" : "保存失败";
                alertWindow.runModal();
            }
            break;
        case "打开剧本":
            let openPanel = NSOpenPanel();
            openPanel.message = "请选择剧本文件保存的位置";
            openPanel.canChooseDirectories = false;
            openPanel.canChooseFiles = true;
            openPanel.allowedFileTypes = ["script"];
            if openPanel.runModal() == NSFileHandlingPanelOKButton {
                CustomLibrary = LibraryHelper.CreateLibraryFromScriptFile(openPanel.URL!);
                LibrariesTree.setDataSource(self);
                LibrariesTree.setDelegate(self);
                LibrariesTree.reloadData();
            }
            break;
        case "导入选中音频":
            if ApplicationHelper.GetSelectedSound() != nil && LibrariesTree.selectedRow != -1 {
                let item = LibrariesTree.itemAtRow(LibrariesTree.selectedRow);
                if item is Library {
                    let lib = item as! Library;
                    //深度拷贝
                    let sound = Sound();
                    sound.FatherLibrary = lib;
                    for key in SoundInfoEnum.AllValues {
                        sound.SoundInfo.updateValue(ApplicationHelper.GetSelectedSound()!.SoundInfo[key.rawValue]!, forKey: key.rawValue);
                    }
                    lib.Sounds.append(sound);
                    LibrariesTree.reloadData();
                }
            }
            break;
        case "生成音频库":
            let openPanel = NSOpenPanel();
            openPanel.message = "请选择音频库保存的位置";
            openPanel.canChooseDirectories = true;
            openPanel.canChooseFiles = false;
            if openPanel.runModal() == NSFileHandlingPanelOKButton {
                let alertWindow = NSAlert();
                alertWindow.messageText = "Hello";
                alertWindow.informativeText = LibraryHelper.CreateDirectoryFromLibrary(CustomLibrary, saveURL: openPanel.URL!) == 0 ? "生成成功" : "生成失败";
                alertWindow.runModal();
            }
            break;
        default:
            break;
        }
    }
    
    func windowWillClose(notification: NSNotification) {
        if EditView.closeStatus == CloseStatusEnum.OK {
            switch (EditView.editType) {
            case EditTypeEnum.CreateLeaf:
                let item = LibrariesTree.itemAtRow(LibrariesTree.selectedRow);
                let lib = item as! Library;
                let newLibLeaf = Library();
                newLibLeaf.LibraryName = EditView.MessageTextFile.stringValue;
                newLibLeaf.FatherLibrary = lib;
                lib.Folders.append(newLibLeaf);
                LibrariesTree.reloadData();
                break;
            case EditTypeEnum.RenameLeaf:
                let item = LibrariesTree.itemAtRow(LibrariesTree.selectedRow);
                if item is Library {
                    (item as! Library).LibraryName = EditView.MessageTextFile.stringValue;
                } else {
                    let fileextension = EditView.MessageTextFile.stringValue.containsString(".wav") ? "" : ".wav";
                    (item as! Sound).SoundInfo.updateValue(EditView.MessageTextFile.stringValue + fileextension, forKey: SoundInfoEnum.FileDisplayName.rawValue);
                }
                LibrariesTree.reloadData();
                break;
            case EditTypeEnum.CreateScript:
                CustomLibrary = Library();
                CustomLibrary.LibraryName = EditView.MessageTextFile.stringValue;
                LibrariesTree.setDataSource(self);
                LibrariesTree.setDelegate(self);
                LibrariesTree.reloadData();
                break;
            default:
                break;
                }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return CustomLibrary;
        } else {
            let lib = item as! Library;
            if index > lib.Sounds.count-1 {
                let folderindex = index - lib.Sounds.count;
                return lib.Folders[folderindex];
            } else {
                return lib.Sounds[index];
            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return item is Library ? true : false;
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return item == nil ? 1 : (item as! Library).Sounds.count+(item as! Library).Folders.count;
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return item == nil ? "" : (item is Library ? (item as! Library).LibraryName : (item as! Sound).SoundInfo[SoundInfoEnum.FileDisplayName.rawValue]);
    }
    
    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
        
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if item is Sound {
            ApplicationHelper.SetSelectedSound(item as! Sound);
            PlayerHelper.InitPlayer();
        }
        return true;
    }
}
