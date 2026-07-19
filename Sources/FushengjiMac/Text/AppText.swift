import Foundation

enum AppText {
    static func t(_ key: String) -> String {
        values[key] ?? key
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: t(key), locale: Locale(identifier: "zh_CN"), arguments: arguments)
    }

    static func money(_ amount: Int) -> String {
        let value = moneyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(value) \(t("currency.yuan"))"
    }

    private static let moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .decimal
        return formatter
    }()

    private static let values: [String: String] = [
        "app.title": "京城账本",
        "app.subtitle": "四十天，一本账，一座城。低买高卖，还清债务，活到结算日。",
        "app.prototypeNote": "独立重制原型：原创占位数据，未复制原版资源或文本。",
        "currency.yuan": "元",

        "menu.game": "游戏",
        "menu.newGame": "新游戏",
        "menu.save": "保存",
        "menu.load": "读取",

        "action.newGame": "新游戏",
        "action.continue": "继续",
        "action.load": "读取存档",
        "action.save": "保存",
        "action.buy": "买入",
        "action.sell": "卖出",
        "action.travel": "前往",
        "action.repay": "还款 1,000",
        "action.borrow": "借款 1,000",
        "action.backToMenu": "回到开始菜单",
        "action.dismiss": "知道了",

        "view.market": "行情",
        "view.inventory": "货袋",
        "view.status": "状态",
        "view.events": "账本与消息",
        "view.bank": "债务",
        "view.travel": "地点",
        "view.settings": "设置",

        "status.dayValue": "第 %d / %d 天",
        "status.day": "日期",
        "status.cash": "现金",
        "status.debt": "债务",
        "status.health": "体力",
        "status.capacity": "容量",
        "status.netWorth": "净值",
        "status.location": "位置",
        "status.quantity": "数量",
        "status.averageCost": "均价",
        "status.price": "价格",
        "status.risk": "风险",
        "status.travelCost": "路费",
        "status.noInventory": "货袋空着，行情再好也只能干看着。",
        "status.noEvents": "今天账本很安静。",
        "status.news": "消息",
        "status.ended": "结局",
        "status.finalScore": "最终净值",

        "settings.sound": "启用音效",
        "settings.quantity": "每次交易数量",
        "settings.quantityValue": "%d 件",

        "message.saved": "存档已写入 Application Support。",
        "message.loaded": "存档已读取。",
        "message.newGame": "新的一局开始了。",
        "message.rankingSaved": "结算已记录到本地排行榜。",
        "message.saveFailed": "保存失败：%@",
        "message.loadFailed": "读取失败：%@",
        "alert.message": "提示",

        "role.runner": "跑街账房",

        "location.gulou": "鼓楼",
        "location.xidan": "西单",
        "location.panjiayuan": "潘家园",
        "location.zhongguancun": "中关村",
        "location.qianmen": "前门",

        "product.oldBooks": "旧书捆",
        "product.cassette": "磁带盒",
        "product.porcelainShard": "瓷片",
        "product.ticketAlbum": "票证册",
        "product.chestnut": "栗子袋",
        "product.digitalWatch": "电子表",

        "unit.stack": "捆",
        "unit.box": "盒",
        "unit.piece": "件",
        "unit.album": "册",
        "unit.bag": "袋",

        "trend.low": "低位",
        "trend.normal": "平稳",
        "trend.high": "高位",

        "event.paperShortage.title": "纸货吃紧",
        "event.paperShortage.body": "旧书摊主说最近纸货不好收，旧书行情被抬了起来。",
        "event.rainyCold.title": "冷雨赶路",
        "event.rainyCold.body": "一场冷雨把鞋袜浇透，体力掉得比账页翻得还快。",
        "event.crowdedPlatform.title": "站台拥挤",
        "event.crowdedPlatform.body": "人潮一挤，货袋里少了几样东西，只能记一笔损耗。",
        "event.collectorTip.title": "熟客点拨",
        "event.collectorTip.body": "一位熟客给了条线索，还顺手塞来一本票证册。",
        "event.watchDemand.title": "电子货走俏",
        "event.watchDemand.body": "柜台上传出消息，电子表今天特别抢手。",

        "news.morningLedger.title": "早报：各处开市，价格未必讲理。",
        "news.morningLedger.body": "消息灵通不等于稳赚，账面现金才是真的底气。",
        "news.marketRumor.title": "传闻：收藏摊近日人多。",
        "news.marketRumor.body": "越热闹的地方越有机会，也越容易出岔子。",
        "news.lateTrain.title": "提示：赶路会耗体力。",
        "news.lateTrain.body": "钱能再赚，体力见底就只能收摊。",

        "ending.victory": "你熬过了期限，还留下了一笔像样的净值。",
        "ending.debtFailure": "债务滚到了无法周转的地步，账本被迫合上。",
        "ending.healthFailure": "体力耗尽，再好的行情也追不上了。",
        "ending.broke": "期限到了，但净值没有达到翻身线。"
    ]
}
