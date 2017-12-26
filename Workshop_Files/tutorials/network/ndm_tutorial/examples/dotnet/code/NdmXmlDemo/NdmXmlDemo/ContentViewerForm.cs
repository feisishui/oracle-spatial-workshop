using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace NDMDemo
{
    public partial class ContentViewerForm : Form
    {
        public ContentViewerForm()
        {
            InitializeComponent();
        }

        private void ContentViewerForm_Load(object sender, EventArgs e)
        {
            this.webBrowser1.Url = this.contentUri;
        }
    }
}
