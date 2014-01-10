describe('player joining', function() {
    var browser2, element2, by2;

    var signInOnBrowserOne = function() {
        var joinButton = browser.element(by.css('[value="Join"]'));
        joinButton.click();

        element(by.model('input.name')).sendKeys('Bob');
        browser.element(by.css('[value="OK"]')).click();
    };

    var signInOnBrowserTwo = function() {
        var joinButton = browser2.element(by2.css('[value="Join"]'));
        joinButton.click();

        element2(by2.model('input.name')).sendKeys('John');
        browser2.element(by.css('[value="OK"]')).click();
    };

    beforeEach(function() {
        //temporary mesure to ensure sockets are abandoned

        browser2 = protractors[1].browser;
        element2 = protractors[1].element;
        by2 = protractors[1].by;

        browser.driver.get('http://127.0.0.1:9433/clear');
        browser.sleep(100);
        browser2.sleep(100);
        browser.get('http://127.0.0.1:4999/#/github');
        browser2.get('http://127.0.0.1:4999/#/github');
    });

    it('should have no players on startup', function() {
        var game = browser.findElement(by.id('game-board'));
        expect(game.isDisplayed()).toBe(false);

        var playerList = element.all(by.repeater('player in players'));
        expect(playerList.count()).toBe(0);
        var playerListOther = element2.all(by2.repeater('player in players'));
        expect(playerListOther.count()).toBe(0);
    });

    it('should add player to both browsers on signin', function() {
        signInOnBrowserOne();

        var playerList = element.all(by.repeater('player in players'));
        expect(playerList.count()).toBe(1);

        var playerListOther = element2.all(by2.repeater('player in players'));
        expect(playerListOther.count()).toBe(1);
    });

    it('should add player to each browsers on signin', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        var playerList = element.all(by.repeater('player in players'));
        expect(playerList.count()).toBe(2);

        var playerListOther = element2.all(by2.repeater('player in players'));
        expect(playerListOther.count()).toBe(2);
    });

    it('should contain one chat message on start', function() {
        var chatList = element.all(by.repeater('message in messages'));
        expect(chatList.count()).toBe(1);

        var chatList2 = element2.all(by2.repeater('message in messages'));
        expect(chatList2.count()).toBe(1);
    });

    it('should show chat message in each browsers after signon', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        element(by.model('message')).sendKeys('WOO');
        browser.actions().sendKeys(protractor.Key.ENTER).perform();

        var chatList = element.all(by.repeater('message in messages'));
        expect(chatList.get(1).getText()).toBe('Bob: WOO');
        expect(chatList.count()).toBe(2);

        var chatList2 = element2.all(by2.repeater('message in messages'));
        expect(chatList2.get(1).getText()).toBe('Bob: WOO');
        expect(chatList2.count()).toBe(2);
    });

    it('should show message from second browser', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        element2(by2.model('message')).sendKeys('WOO');
        browser2.actions().sendKeys(protractor.Key.ENTER).perform();

        var chatList = element.all(by.repeater('message in messages'));
        expect(chatList.get(1).getText()).toBe('John: WOO');
        expect(chatList.count()).toBe(2);

        var chatList2 = element2.all(by2.repeater('message in messages'));
        expect(chatList2.get(1).getText()).toBe('John: WOO');
        expect(chatList2.count()).toBe(2);
    });

    it('should show game when two players are ready', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        browser.findElement(by.id('ready-button')).click();
        browser2.findElement(by2.id('ready-button')).click();

        var board = browser.findElement(by.id('game-board'));
        expect(board.isDisplayed()).toBe(true)
        var board2 = browser2.findElement(by2.id('game-board'));
        expect(board2.isDisplayed()).toBe(true)
    });
        
    it('should show ready next to player that is ready', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        browser.findElement(by.id('ready-button')).click();

        var board = browser.findElement(by.id('game-board'));
        expect(board.isDisplayed()).toBe(false)

        var playerList = element.all(by.repeater('player in players'));
        var playerOne = playerList.get(0);
        var playerTwo = playerList.get(1);

        var ready = playerOne.findElement(by.className("ready-label"));
        expect(ready.isDisplayed()).toBe(true)
        var ready2 = playerTwo.findElement(by.className("ready-label"));
        expect(ready2.isDisplayed()).toBe(false)

        var board = browser2.findElement(by2.id('game-board'));
        expect(board.isDisplayed()).toBe(false)

        var playerList = element2.all(by2.repeater('player in players'));
        var playerOne = playerList.get(0);
        var playerTwo = playerList.get(1);

        var ready = playerOne.findElement(by2.className("ready-label"));
        expect(ready.isDisplayed()).toBe(true)
        var ready2 = playerTwo.findElement(by2.className("ready-label"));
        expect(ready2.isDisplayed()).toBe(false)
    });
        
    it('should have correct names when two players are ready', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        browser.findElement(by.id('ready-button')).click();
        browser2.findElement(by2.id('ready-button')).click();

        var seatAName = browser.findElement(by.id('seatAName'));
        expect(seatAName.getText()).toEqual("Bob");
        var seatCName = browser.findElement(by.id('seatCName'));
        expect(seatCName.getText()).toEqual("John");
    });

    it('should have opposite names for browser 2 when two players are ready', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        browser.findElement(by.id('ready-button')).click();
        browser2.findElement(by2.id('ready-button')).click();

        var seatAName = browser2.findElement(by2.id('seatAName'));
        expect(seatAName.getText()).toEqual("John");
        var seatCName = browser2.findElement(by2.id('seatCName'));
        expect(seatCName.getText()).toEqual("Bob");
    });

    it('should have correct first player highlighted on browser 2', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        browser.findElement(by.id('ready-button')).click();
        browser2.findElement(by2.id('ready-button')).click();

        var seatAActive = browser2.findElement(by2.id('seatAActive'));
        var seatCActive = browser2.findElement(by2.id('seatCActive'));
        seatAActive.isDisplayed().then(function(displayedA) {
            seatCActive.isDisplayed().then(function(displayedC) {
                expect(displayedA).toEqual(!displayedC);
            });
        });
    });

    it('should have correct first player highlighted on browser', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        browser.findElement(by.id('ready-button')).click();
        browser2.findElement(by2.id('ready-button')).click();

        var seatAActive = browser.findElement(by.id('seatAActive'));
        var seatAActive2 = browser2.findElement(by2.id('seatAActive'));

        seatAActive.isDisplayed().then(function(displayedA) {
            seatAActive2.isDisplayed().then(function(displayedA2) {
                expect(displayedA).toEqual(!displayedA2);
            });
        });
    });

});
