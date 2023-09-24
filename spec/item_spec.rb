# frozen_string_literal: true

describe HiringTrends::Item do
  describe ".load" do
    it "loads the items from the API", vcr: true do
      mock_file = instance_double("File")
      allow(mock_file).to receive(:write)
      allow(File).to receive(:open).and_yield(mock_file)
      # allow(File).to receive(:exist?).with("data/item_2396027.json").and_return(false)

      item = described_class.load(item_id: 2396027, force_api_source: true)
      expect(item.id).to eq(2396027)
      expect(item.title).to eq("Ask HN: Who is Hiring? (April 2011)")
      expect(mock_file).to have_received(:write)
    end

    it "loads the items from disk" do
      allow(File).to receive(:exist?).with("data/item_2396027.json").and_return(true)
      allow(File).to receive(:read).with("data/item_2396027.json").and_return(%{
        {
          "id":2396027,
          "created_at":
          "2011-04-01T13:11:26.000Z",
          "created_at_i":1301663486,
          "type":"story","author":
          "whoishiring",
          "title":"Ask HN: Who is Hiring? (April 2011)"
        }
      })

      item = described_class.load(item_id: 2396027)
      expect(item.id).to eq(2396027)
      expect(item.title).to eq("Ask HN: Who is Hiring? (April 2011)")
    end
  end

  describe "#initalize" do
    it "initializes correctly" do
      described_class.new({})
    end
  end

  describe "#month" do
    it "returns the formatted month of the item" do
      api_item = { "title" => "Ask HN: Who is Hiring? (April 2011)" }
      item = described_class.new(api_item)
      expect(item.month).to eq("Apr11")
    end
  end

  describe "#to_record" do
    it "formats a record for the publsihed dataset" do
      api_item = {
        "id" => 2396027,
        "title" => "Ask HN: Who is Hiring? (April 2011)",
        "points" => 280,
        "children" => [{ "id" => 2404566, "created_at" => "2011-04-03T23:43:58.000Z", "text" => "this is the job descripton" }]
      }

      item = described_class.new(api_item)
      expect(item.to_record).to eq({
        month: "Apr11",
        num_comments: 1,
        points: 280,
        terms: nil
      })
    end
  end

  describe "#save" do
    it "saves the item to disk" do
      mock_file = instance_double("File")
      allow(mock_file).to receive(:write)
      allow(File).to receive(:open).and_yield(mock_file)
      api_item = {
        "id" => 2396027,
        "title" => "Ask HN: Who is Hiring? (April 2011)",
        "points" => 280
      }

      item = described_class.new(api_item)
      item.save
      expect(mock_file).to have_received(:write)
    end
  end

  describe "#analyze" do
    subject { described_class.new(api_item) }

    let(:api_item) {
      {
        "id" => 2396027,
        "title" => "Ask HN: Who is Hiring? (April 2011)",
        "num_comments" => 295,
        "points" => 280,
        "children" => comments
      }
    }
    let(:terms) {
      {
        "Ruby" => { count: 0, percentage: 0, full_term: "Ruby" },
        "Python" => { count: 0, percentage: 0, full_term: "Python" },
        "JavaScript" => { count: 0, percentage: 0, full_term: "JavaScript" },
        "AngularJS" => { count: 0, percentage: 0, full_term: "AngularJS/js[Angular]" },
        "backbone" => { count: 0, percentage: 0, full_term: "backbone/js[backbone]" },
        "node.js" => { count: 0, percentage: 0, full_term: "node.js/js[node]" }
      }
    }
    let(:dictionary) { 
      instance_double("HiringTrends::TermsDictionary")
    }

    before do
      allow(HiringTrends::TermsDictionary).to receive(:new).and_return(dictionary)
      allow(dictionary).to receive(:term_counts_template).and_return(terms)
    end

    context "when words have slash separatos" do
      let(:comments) {
        [
          { "text" => "This first comment has ruby in it." },
          { "text" => "in this comment is ruby/javascript" }
        ]
      }

      it "separates words" do
        subject.analyze(dictionary)

        expect(subject.terms_data["Ruby"][:count]).to eq(2)
        expect(subject.terms_data["JavaScript"][:count]).to eq(1)
      end
    end

    context "when words have comma separators" do
      let(:comments) {
        [
          { "text" => "This first comment has ruby in it." },
          { "text" => "in this comment is ruby, javascript." }
        ]
      }

      it "separates words" do
        subject.analyze(dictionary)

        expect(subject.terms_data["Ruby"][:count]).to eq(2)
      end
    end

    context "when words have trailing periods at end of a sentence" do
      let(:comments) {
        [
          { "text" => "This first comment has ruby in it." },
          { "text" => "in this comment is ruby, javascript." }
        ]
      }

      it "separates words with periods at end of sentence" do
        subject.analyze(dictionary)

        expect(subject.terms_data["Ruby"][:count]).to eq(2)
        expect(subject.terms_data["JavaScript"][:count]).to eq(1)
      end
    end

    context "when words have different case" do
      let(:comments) {
        [
          { "text" => "This first comment has ruby in it." },
          { "text" => "in this comment is ruby, javascript." }
        ]
      }

      it "is case insensitive" do
        subject.analyze(dictionary)

        expect(subject.terms_data["Ruby"][:count]).to eq(2)
        expect(subject.terms_data["JavaScript"][:count]).to eq(1)
      end
    end

    context "when comment has Objective-c" do
      let(:comments) {
        [
          { "text" => "Primary languages are javascript and python, with a history in php and a little bit of Objective-c. I have experience with many of the common client-side frameworks like Backbone, Knockout, etc." },
          { "text" => "in this comment is ruby, javascript." }
        ]
      }
      let(:terms) {
        {
          "JavaScript" => { count: 0, percentage: 0, full_term: "JavaScript" },
          "Objective-C" => { count: 0, percentage: 0, full_term: "Objective-C/alias[Objective-C|ObjectiveC|Objective C]" },
          "PHP" => { count: 0, percentage: 0, full_term: "PHP" },
          "Python" => { count: 0, percentage: 0, full_term: "Python" }
        }
      }

      it "counts it" do
        subject.analyze(dictionary)
        expect(subject.terms_data["Objective-C"][:count]).to eq(1)
      end
    end

    context "when terms are quoted" do
      let(:comments) {
        [
          { "text" => "Javascript  ['angular','backbone','node']" },
          { "text" => "in this comment is ruby, javascript." }
        ]
      }

      it "ignore quotes" do
        subject.analyze(dictionary)
        expect(subject.terms_data["AngularJS"][:count]).to eq(1)
      end
    end

    context "when terms are multiple words" do
      let(:comments) {
        [
          { "text" => "Javascript visual basic web services" },
          { "text" => "in this comment is ruby, javascript." }
        ]
      }
      let(:terms) {
        {
          "Visual Basic" => { count: 0, percentage: 0, full_term: "Visual Basic" },
          "Web services" => { count: 0, percentage: 0, full_term: "Web services" },
          "node.js" => { count: 0, percentage: 0, full_term: "node.js/js[node]" }
        }
      }

      it "counts multi-word terms" do
        subject.analyze(dictionary)
        expect(subject.terms_data["Visual Basic"][:count]).to eq(1)
      end
    end

    context "when terms begin with a dot/period" do
      let(:comments) {
        [
          { "text" => "Javascript visual basic c web services C#/.NET" },
          { "text" => "in this comment is ruby, javascript." }
        ]
      }
      let(:terms) {
        {
          ".NET" => { count: 0, percentage: 0, full_term: ".NET" }
        }
      }

      it "counts .net" do
        subject.analyze(dictionary)
        expect(subject.terms_data[".NET"][:count]).to eq(1)
      end
    end

    context "when comment has RabbitMQ" do
      let(:comments) {
        [
          { "text" => "Shirts.io – Fremont, CA<p>Want a free custom t-shirt? Read on!<p><i>The Company</i><p><a href=\"https://www.shirts.io\" rel=\"nofollow\">https:&#x2F;&#x2F;www.shirts.io</a> is an online fulfillment service that prints, packs, and delivers custom printed t-shirts, posters, and phone cases.<p>Our mission is to empower our customers to start their own merchandising business by offering well-designed online software with world-class production infrastructure.<p>We are headquartered in Silicon Valley with facilities in California, Pennsylvania and Indiana.<p><i>The Role</i><p>We are looking for junior, mid, and senior full-stack web developers and&#x2F;or software developers with all or some of the following.<p><pre><code> Backend skill sets:\\n\\n - Python, Django, PHP, MySQL, Postgresql\\n - Redis or RabbitMQ\\n - Python Image Library or Ghostscript experience\\n\\n Frontend skill sets:\\n\\n - JavaScript, jQuery\\n - Nice to have: AngularJS, NodeJS, Express.js\\n\\n DevOp skill sets:\\n\\n - Heroku or Amazon AWS, Amazon S3\\n - NewRelic or Sentry for error tracking, Loggly for logging\\n\\n Testing&#x2F;QA skill sets:\\n\\n - Continuous Integration\\n - Selenium testing\\n\\n The Benefits\\n\\n - Competitive salary\\n - Newly furnished office\\n - Professional Mac or PC equipment\\n - Catered meals on Fridays\\n</code></pre>\\nInterested in helping us making printing custom apparel and products easy? Email us at info@shirts.io<p>Just interested in your free custom t-shirt? Take a look at our site and implement a project with our API then email info@shirts.io" },
          { "text" => "New York (NYC) Thomson Reuters<p>Worki\\u0010ng on the team that makes Eikon and the underlying platform. You can learn about the group&#x27;s work, mission, and leadership by jumping to 1:45:00 in this video <a href=\"https://www.media-server.com/m/p/moaghpeu\" rel=\"nofollow\">https:&#x2F;&#x2F;www.media-server.com&#x2F;m&#x2F;p&#x2F;moaghpeu</a><p>Jobs in product development, engineer in test, and dev ops.<p>We use: \\n - HTML5&#x2F;JS&#x2F;Angular\\n - Mobile (iOS&#x2F;Android&#x2F;hybrid)\\n - C++\\n - Hadoop&#x2F;HBase\\n - DevOps: Java, puppet, Sensu, RabbitMQ, ElasticSearch<p>Expertise in one of those sets is a big plus, but get in touch if you have interest and I&#x27;ll see if we have a spot that interests you. Happy to grab coffee with anyone to have a casual chat about the possibilities.<p>Contact: Lou Franco lou.franco -at- thomsonreuters.com" },
          { "text" => "XP-Dev.com - Remote - <a href=\"https://xp-dev.com\" rel=\"nofollow\">https:&#x2F;&#x2F;xp-dev.com</a><p>XP-Dev.com does version control and project hosting (in the same market as Github, Bitbucket, etc). Profitable and bootstrapped.<p>Looking for backend and frontend engineers who would like to get their hands dirty in Subversion, Git and Mercurial. You will be working on new features on the platform that may involve work on the whole stack. You will be liaising directly with real users. Deployments are really quick, and you get to see the impact of your work almost immediately.<p>Stack:<p><pre><code> - Nginx, Apache\\n - Java (Core, Wicket, Hibernate)\\n - Python (mainly for scripting)\\n - Linux\\n - AngularJS, JQuery\\n - MySQL\\n - Redis\\n - RabbitMQ\\n - Fabric\\n</code></pre>\\nThere are other products in the pipeline - most of which are akin to xp-dev.com (hosting&#x2F;productivity platforms). So, there is plenty of room to switch products and try out new things: <a href=\"https://deployer.vc\" rel=\"nofollow\">https:&#x2F;&#x2F;deployer.vc</a>, <a href=\"https://zoned.io\" rel=\"nofollow\">https:&#x2F;&#x2F;zoned.io</a> amongst them.<p>What we&#x27;re looking for:<p><pre><code> - Self starters\\n - Sound understanding of programming\\n you don&#x27;t need to be a Java&#x2F;Python&#x2F;JavaScript guru\\n</code></pre>\\nBenefits:<p><pre><code> - No keeping track of holidays\\n - Flexible working hours\\n - Flexible working conditions (see below)\\n</code></pre>\\nPosition location is remote. You&#x27;ll need to factor in working from home or from a shared space near you (all will be paid for).<p>To apply, just drop a short cover email describing yourself and your CV to rs@exentriquesolutions.com" }
        ]
      }
      let(:terms) {
        {
          "RabbitMQ" => { count: 0, percentage: 0, full_term: "RabbitMQ" }
        }
      }

      it "counts it" do
        subject.analyze(dictionary)
        expect(subject.terms_data["RabbitMQ"][:count]).to eq(3)
      end
    end
  end
end
