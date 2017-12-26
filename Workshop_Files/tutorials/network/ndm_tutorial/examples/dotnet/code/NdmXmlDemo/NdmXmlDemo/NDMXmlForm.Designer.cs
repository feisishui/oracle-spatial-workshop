using System.Collections;
using System.Windows.Forms;
namespace NDMDemo
{


    partial class NDMXmlForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

       

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
            removeXmlTmpFile();
        }


        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.networkAnalysisControl = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.tspPanel = new System.Windows.Forms.Panel();
            this.label9 = new System.Windows.Forms.Label();
            this.tspFlagControl = new System.Windows.Forms.ComboBox();
            this.tspPointsControl = new System.Windows.Forms.RichTextBox();
            this.labelX = new System.Windows.Forms.Label();
            this.withinCostPanel = new System.Windows.Forms.Panel();
            this.label7 = new System.Windows.Forms.Label();
            this.costControl = new System.Windows.Forms.TextBox();
            this.nearestNeighborsPanel = new System.Windows.Forms.Panel();
            this.label6 = new System.Windows.Forms.Label();
            this.noOfNodesControl = new System.Windows.Forms.TextBox();
            this.linkCostCalculatorControl = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.reqDetailedInfoCkb = new System.Windows.Forms.CheckBox();
            this.reqGeomInfoCkb = new System.Windows.Forms.CheckBox();
            this.networkConstraintControl = new System.Windows.Forms.ListBox();
            this.button1 = new System.Windows.Forms.Button();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.endPointControl = new System.Windows.Forms.TextBox();
            this.startPointControl = new System.Windows.Forms.TextBox();
            this.outputControl = new System.Windows.Forms.RichTextBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.responseXmlLink = new System.Windows.Forms.LinkLabel();
            this.requestXmlLink = new System.Windows.Forms.LinkLabel();
            this.groupBox1.SuspendLayout();
            this.tspPanel.SuspendLayout();
            this.withinCostPanel.SuspendLayout();
            this.nearestNeighborsPanel.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // networkAnalysisControl
            // 
            this.networkAnalysisControl.FormattingEnabled = true;
            this.networkAnalysisControl.Location = new System.Drawing.Point(106, 23);
            this.networkAnalysisControl.Name = "networkAnalysisControl";
            this.networkAnalysisControl.Size = new System.Drawing.Size(251, 21);
            this.networkAnalysisControl.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 26);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(91, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Network Analysis:";
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox1.Controls.Add(this.tspPanel);
            this.groupBox1.Controls.Add(this.withinCostPanel);
            this.groupBox1.Controls.Add(this.nearestNeighborsPanel);
            this.groupBox1.Controls.Add(this.linkCostCalculatorControl);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.reqDetailedInfoCkb);
            this.groupBox1.Controls.Add(this.reqGeomInfoCkb);
            this.groupBox1.Controls.Add(this.networkConstraintControl);
            this.groupBox1.Controls.Add(this.button1);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.endPointControl);
            this.groupBox1.Controls.Add(this.startPointControl);
            this.groupBox1.Location = new System.Drawing.Point(15, 63);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(672, 234);
            this.groupBox1.TabIndex = 2;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Input";
            // 
            // tspPanel
            // 
            this.tspPanel.Controls.Add(this.label9);
            this.tspPanel.Controls.Add(this.tspFlagControl);
            this.tspPanel.Controls.Add(this.tspPointsControl);
            this.tspPanel.Controls.Add(this.labelX);
            this.tspPanel.Location = new System.Drawing.Point(0, 19);
            this.tspPanel.Name = "tspPanel";
            this.tspPanel.Size = new System.Drawing.Size(666, 116);
            this.tspPanel.TabIndex = 17;
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(56, 88);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(54, 13);
            this.label9.TabIndex = 3;
            this.label9.Text = "TSP Flag:";
            // 
            // tspFlagControl
            // 
            this.tspFlagControl.FormattingEnabled = true;
            this.tspFlagControl.Location = new System.Drawing.Point(114, 85);
            this.tspFlagControl.Name = "tspFlagControl";
            this.tspFlagControl.Size = new System.Drawing.Size(300, 21);
            this.tspFlagControl.TabIndex = 2;
            // 
            // tspPointsControl
            // 
            this.tspPointsControl.Location = new System.Drawing.Point(14, 31);
            this.tspPointsControl.Name = "tspPointsControl";
            this.tspPointsControl.Size = new System.Drawing.Size(400, 36);
            this.tspPointsControl.TabIndex = 1;
            this.tspPointsControl.Text = "199887338 199592218 199473962 199699559";
            // 
            // labelX
            // 
            this.labelX.AutoSize = true;
            this.labelX.Location = new System.Drawing.Point(11, 12);
            this.labelX.Name = "labelX";
            this.labelX.Size = new System.Drawing.Size(159, 13);
            this.labelX.TabIndex = 0;
            this.labelX.Text = "Node ID\'s (separated by space):";
            // 
            // withinCostPanel
            // 
            this.withinCostPanel.Controls.Add(this.label7);
            this.withinCostPanel.Controls.Add(this.costControl);
            this.withinCostPanel.Location = new System.Drawing.Point(258, 19);
            this.withinCostPanel.Name = "withinCostPanel";
            this.withinCostPanel.Size = new System.Drawing.Size(200, 42);
            this.withinCostPanel.TabIndex = 16;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(4, 16);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(31, 13);
            this.label7.TabIndex = 15;
            this.label7.Text = "Cost:";
            // 
            // costControl
            // 
            this.costControl.Location = new System.Drawing.Point(37, 12);
            this.costControl.Name = "costControl";
            this.costControl.Size = new System.Drawing.Size(100, 20);
            this.costControl.TabIndex = 14;
            this.costControl.Text = "200";
            // 
            // nearestNeighborsPanel
            // 
            this.nearestNeighborsPanel.Controls.Add(this.label6);
            this.nearestNeighborsPanel.Controls.Add(this.noOfNodesControl);
            this.nearestNeighborsPanel.Location = new System.Drawing.Point(258, 19);
            this.nearestNeighborsPanel.Name = "nearestNeighborsPanel";
            this.nearestNeighborsPanel.Size = new System.Drawing.Size(201, 42);
            this.nearestNeighborsPanel.TabIndex = 15;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(3, 16);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(58, 13);
            this.label6.TabIndex = 14;
            this.label6.Text = "Neighbors:";
            // 
            // noOfNodesControl
            // 
            this.noOfNodesControl.Location = new System.Drawing.Point(79, 13);
            this.noOfNodesControl.Name = "noOfNodesControl";
            this.noOfNodesControl.Size = new System.Drawing.Size(100, 20);
            this.noOfNodesControl.TabIndex = 13;
            this.noOfNodesControl.Text = "10";
            // 
            // linkCostCalculatorControl
            // 
            this.linkCostCalculatorControl.FormattingEnabled = true;
            this.linkCostCalculatorControl.Items.AddRange(new object[] {
            "Default Link Cost Calculator",
            "custom.LinkHopCostCalculator",
            "custom.LinkTimeCostCalculator",
            "custom.TrafficLinkCostCalculator"});
            this.linkCostCalculatorControl.Location = new System.Drawing.Point(114, 141);
            this.linkCostCalculatorControl.Name = "linkCostCalculatorControl";
            this.linkCostCalculatorControl.Size = new System.Drawing.Size(300, 21);
            this.linkCostCalculatorControl.TabIndex = 12;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(9, 144);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(104, 13);
            this.label2.TabIndex = 11;
            this.label2.Text = "Link Cost Calculator:";
            // 
            // reqDetailedInfoCkb
            // 
            this.reqDetailedInfoCkb.AutoSize = true;
            this.reqDetailedInfoCkb.Location = new System.Drawing.Point(208, 181);
            this.reqDetailedInfoCkb.Name = "reqDetailedInfoCkb";
            this.reqDetailedInfoCkb.Size = new System.Drawing.Size(308, 17);
            this.reqDetailedInfoCkb.TabIndex = 10;
            this.reqDetailedInfoCkb.Text = "Retrieve Detailed Resulting Path Link and Node Information";
            this.reqDetailedInfoCkb.UseVisualStyleBackColor = true;
            // 
            // reqGeomInfoCkb
            // 
            this.reqGeomInfoCkb.AutoSize = true;
            this.reqGeomInfoCkb.Location = new System.Drawing.Point(12, 181);
            this.reqGeomInfoCkb.Name = "reqGeomInfoCkb";
            this.reqGeomInfoCkb.Size = new System.Drawing.Size(169, 17);
            this.reqGeomInfoCkb.TabIndex = 6;
            this.reqGeomInfoCkb.Text = "Retrieve Geometry Information";
            this.reqGeomInfoCkb.UseVisualStyleBackColor = true;
            // 
            // networkConstraintControl
            // 
            this.networkConstraintControl.FormattingEnabled = true;
            this.networkConstraintControl.Items.AddRange(new object[] {
            "custom.NoHighwayConstraint",
            "custom.ProhibitedZoneConstraint",
            "oracle.spatial.router.ndm.TruckHeightConstraint",
            "oracle.spatial.router.ndm.TruckLegalConstraint"});
            this.networkConstraintControl.Location = new System.Drawing.Point(114, 69);
            this.networkConstraintControl.Name = "networkConstraintControl";
            this.networkConstraintControl.Size = new System.Drawing.Size(300, 56);
            this.networkConstraintControl.TabIndex = 9;
            // 
            // button1
            // 
            this.button1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.button1.Location = new System.Drawing.Point(550, 205);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(116, 23);
            this.button1.TabIndex = 8;
            this.button1.Text = "Perform Analysis";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(9, 69);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(105, 13);
            this.label5.TabIndex = 5;
            this.label5.Text = "Network Constraints:";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(255, 34);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(56, 13);
            this.label4.TabIndex = 3;
            this.label4.Text = "End Point:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(52, 34);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(59, 13);
            this.label3.TabIndex = 2;
            this.label3.Text = "Start Point:";
            // 
            // endPointControl
            // 
            this.endPointControl.Location = new System.Drawing.Point(314, 31);
            this.endPointControl.Name = "endPointControl";
            this.endPointControl.Size = new System.Drawing.Size(100, 20);
            this.endPointControl.TabIndex = 1;
            this.endPointControl.Text = "199652792";
            // 
            // startPointControl
            // 
            this.startPointControl.AccessibleName = "";
            this.startPointControl.Location = new System.Drawing.Point(114, 31);
            this.startPointControl.Name = "startPointControl";
            this.startPointControl.Size = new System.Drawing.Size(100, 20);
            this.startPointControl.TabIndex = 0;
            this.startPointControl.Text = "199520844";
            // 
            // outputControl
            // 
            this.outputControl.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.outputControl.ImeMode = System.Windows.Forms.ImeMode.On;
            this.outputControl.Location = new System.Drawing.Point(12, 19);
            this.outputControl.Name = "outputControl";
            this.outputControl.ReadOnly = true;
            this.outputControl.Size = new System.Drawing.Size(654, 273);
            this.outputControl.TabIndex = 3;
            this.outputControl.Text = "";
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.Controls.Add(this.responseXmlLink);
            this.groupBox2.Controls.Add(this.requestXmlLink);
            this.groupBox2.Controls.Add(this.outputControl);
            this.groupBox2.Location = new System.Drawing.Point(15, 315);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(672, 332);
            this.groupBox2.TabIndex = 5;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Output";
            // 
            // responseXmlLink
            // 
            this.responseXmlLink.AutoSize = true;
            this.responseXmlLink.Enabled = false;
            this.responseXmlLink.Location = new System.Drawing.Point(557, 305);
            this.responseXmlLink.Name = "responseXmlLink";
            this.responseXmlLink.Size = new System.Drawing.Size(105, 13);
            this.responseXmlLink.TabIndex = 5;
            this.responseXmlLink.TabStop = true;
            this.responseXmlLink.Tag = "";
            this.responseXmlLink.Text = "Show XML response";
            this.responseXmlLink.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkLabel2_LinkClicked);
            // 
            // requestXmlLink
            // 
            this.requestXmlLink.AutoSize = true;
            this.requestXmlLink.Enabled = false;
            this.requestXmlLink.Location = new System.Drawing.Point(364, 305);
            this.requestXmlLink.Name = "requestXmlLink";
            this.requestXmlLink.Size = new System.Drawing.Size(148, 13);
            this.requestXmlLink.TabIndex = 4;
            this.requestXmlLink.TabStop = true;
            this.requestXmlLink.Tag = "";
            this.requestXmlLink.Text = "Show generated XML request";
            this.requestXmlLink.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkLabel1_LinkClicked);
            // 
            // NDMXmlForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(699, 659);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.networkAnalysisControl);
            this.Name = "NDMXmlForm";
            this.Text = "Oracle Spatial Network Data Model Demo";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.tspPanel.ResumeLayout(false);
            this.tspPanel.PerformLayout();
            this.withinCostPanel.ResumeLayout(false);
            this.withinCostPanel.PerformLayout();
            this.nearestNeighborsPanel.ResumeLayout(false);
            this.nearestNeighborsPanel.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox networkAnalysisControl;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox endPointControl;
        private System.Windows.Forms.TextBox startPointControl;
        private System.Windows.Forms.RichTextBox outputControl;
        private System.Windows.Forms.ListBox networkConstraintControl;
        private System.Windows.Forms.GroupBox groupBox2;
        private CheckBox reqDetailedInfoCkb;
        private CheckBox reqGeomInfoCkb;
        private LinkLabel requestXmlLink;
        private LinkLabel responseXmlLink;
        private Panel nearestNeighborsPanel;
        private Label label6;
        private TextBox noOfNodesControl;
        private Label label2;
        private ComboBox linkCostCalculatorControl;
        private Panel withinCostPanel;
        private Label label7;
        private TextBox costControl;
        private Panel tspPanel;
        private Label label9;
        private ComboBox tspFlagControl;
        private RichTextBox tspPointsControl;
        private Label labelX;
    }


}

